/* mpi_shim/mpi.h - TEST-ONLY stand-in for MPI, for machines without an MPI
 * installation. It emulates the few calls jacobi_mpi.c uses by fork()ing the
 * ranks and connecting them with pipes. Do NOT use it for real runs: with a real
 * MPI, compile with mpicc and without -Impi_shim.
 *
 * Number of ranks: environment variable MPI_SHIM_NP (default 2, max 16).
 * Supported: MPI_Init/Finalize, Comm_rank/size, Sendrecv, Barrier, Allreduce
 * (MPI_SUM/MPI_MAX on MPI_DOUBLE/MPI_INT/MPI_LONG), Wtime.
 */
#ifndef MPI_SHIM_H
#define MPI_SHIM_H

#include <poll.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/wait.h>

typedef int MPI_Comm;
typedef int MPI_Datatype;
typedef int MPI_Op;
typedef struct { int dummy; } MPI_Status;

#define MPI_COMM_WORLD 0
#define MPI_DOUBLE 1
#define MPI_INT    2
#define MPI_LONG   3
#define MPI_SUM    1
#define MPI_MAX    2
#define MPI_STATUS_IGNORE ((MPI_Status *) 0)

#define SHIM_MAXP 16
static int   shim_rank = 0, shim_size = 1;
static int   shim_fd[SHIM_MAXP][SHIM_MAXP][2];   /* pipe from rank s to rank d */
static pid_t shim_kid[SHIM_MAXP];

static inline size_t shim_sz(MPI_Datatype t)
{
    return t == MPI_DOUBLE ? sizeof(double) : t == MPI_INT ? sizeof(int) : sizeof(long);
}

/* Send sn bytes on wfd while receiving rn bytes from rfd (never deadlocks). */
static inline void shim_exchange(int wfd, const char *sb, size_t sn,
                                 int rfd, char *rb, size_t rn)
{
    size_t so = 0, ro = 0;
    while (so < sn || ro < rn) {
        struct pollfd p[2]; int k = 0, wi = -1, ri = -1;
        if (so < sn) { p[k].fd = wfd; p[k].events = POLLOUT; p[k].revents = 0; wi = k++; }
        if (ro < rn) { p[k].fd = rfd; p[k].events = POLLIN;  p[k].revents = 0; ri = k++; }
        if (poll(p, k, 30000) <= 0) { fprintf(stderr, "shim: timeout/deadlock\n"); _exit(97); }
        if (wi >= 0 && (p[wi].revents & POLLOUT)) {
            ssize_t r = write(wfd, sb + so, sn - so);
            if (r > 0) so += (size_t) r;
        }
        if (ri >= 0 && (p[ri].revents & (POLLIN | POLLHUP))) {
            ssize_t r = read(rfd, rb + ro, rn - ro);
            if (r > 0) ro += (size_t) r;
            else if (r == 0) { fprintf(stderr, "shim: peer closed\n"); _exit(98); }
        }
    }
}

static inline int MPI_Init(int *argc, char ***argv)
{
    (void) argc; (void) argv;
    const char *e = getenv("MPI_SHIM_NP");
    shim_size = e ? atoi(e) : 2;
    if (shim_size < 1 || shim_size > SHIM_MAXP) { fprintf(stderr, "shim: bad MPI_SHIM_NP\n"); exit(1); }
    for (int s = 0; s < shim_size; s++)
        for (int d = 0; d < shim_size; d++) {
            if (pipe(shim_fd[s][d]) != 0) { perror("pipe"); exit(1); }
            fcntl(shim_fd[s][d][0], F_SETFL, O_NONBLOCK);
            fcntl(shim_fd[s][d][1], F_SETFL, O_NONBLOCK);
        }
    fflush(NULL);
    for (int r = 1; r < shim_size; r++) {
        pid_t pid = fork();
        if (pid < 0) { perror("fork"); exit(1); }
        if (pid == 0) { shim_rank = r; return 0; }
        shim_kid[r] = pid;
    }
    return 0;
}

static inline int MPI_Comm_rank(MPI_Comm c, int *r) { (void) c; *r = shim_rank; return 0; }
static inline int MPI_Comm_size(MPI_Comm c, int *s) { (void) c; *s = shim_size; return 0; }

static inline int MPI_Sendrecv(const void *sb, int sc, MPI_Datatype st, int dest, int stag,
                               void *rb, int rc, MPI_Datatype rt, int src, int rtag,
                               MPI_Comm c, MPI_Status *status)
{
    (void) stag; (void) rtag; (void) c; (void) status;
    shim_exchange(shim_fd[shim_rank][dest][1], (const char *) sb, (size_t) sc * shim_sz(st),
                  shim_fd[src][shim_rank][0],  (char *) rb,       (size_t) rc * shim_sz(rt));
    return 0;
}

/* Gather to rank 0, reduce, send the result back (also acts as a barrier). */
static inline int MPI_Allreduce(const void *sb, void *rb, int n, MPI_Datatype t,
                                MPI_Op op, MPI_Comm c)
{
    (void) c;
    size_t bytes = (size_t) n * shim_sz(t);
    char tmp[256];
    if (bytes > sizeof tmp) { fprintf(stderr, "shim: allreduce too large\n"); exit(1); }
    if (shim_rank != 0) {
        shim_exchange(shim_fd[shim_rank][0][1], (const char *) sb, bytes, -1, NULL, 0);
        shim_exchange(-1, NULL, 0, shim_fd[0][shim_rank][0], (char *) rb, bytes);
        return 0;
    }
    char acc[256];
    for (size_t i = 0; i < bytes; i++) acc[i] = ((const char *) sb)[i];
    for (int r = 1; r < shim_size; r++) {
        shim_exchange(-1, NULL, 0, shim_fd[r][0][0], tmp, bytes);
        for (int i = 0; i < n; i++) {
            if (t == MPI_DOUBLE) {
                double a = ((double *) acc)[i], b = ((double *) tmp)[i];
                ((double *) acc)[i] = (op == MPI_SUM) ? a + b : (a > b ? a : b);
            } else if (t == MPI_INT) {
                int a = ((int *) acc)[i], b = ((int *) tmp)[i];
                ((int *) acc)[i] = (op == MPI_SUM) ? a + b : (a > b ? a : b);
            } else {
                long a = ((long *) acc)[i], b = ((long *) tmp)[i];
                ((long *) acc)[i] = (op == MPI_SUM) ? a + b : (a > b ? a : b);
            }
        }
    }
    for (size_t i = 0; i < bytes; i++) ((char *) rb)[i] = acc[i];
    for (int r = 1; r < shim_size; r++)
        shim_exchange(shim_fd[0][r][1], acc, bytes, -1, NULL, 0);
    return 0;
}

static inline int MPI_Barrier(MPI_Comm c)
{
    int x = 0, y = 0;
    return MPI_Allreduce(&x, &y, 1, MPI_INT, MPI_SUM, c);
}

static inline double MPI_Wtime(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double) ts.tv_sec + 1e-9 * (double) ts.tv_nsec;
}

static inline int MPI_Finalize(void)
{
    if (shim_rank == 0) {
        int bad = 0;
        for (int r = 1; r < shim_size; r++) {
            int st = 0;
            waitpid(shim_kid[r], &st, 0);
            if (!WIFEXITED(st) || WEXITSTATUS(st) > 1) bad = 1;   /* 1 = solver "no convergence" */
        }
        if (bad) { fprintf(stderr, "shim: a rank failed\n"); exit(2); }
    }
    return 0;
}

#endif
