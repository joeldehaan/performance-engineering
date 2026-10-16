#!/usr/bin/env python3
"""Plot the strong- and weak-scaling results written by the two shell scripts.

Input:  strong-scaling.csv and weak-scaling.csv with the columns
        threads,run1,...,runN (wall time in seconds).
Output: strong-scaling.png and weak-scaling.png

Each figure has two panels: speedup (left) and efficiency (right).
All quantities are relative to the first (lowest) thread count in the CSV,
using the median of its runs as the baseline time T(base).

  strong scaling: speedup = T(base) / T(p), compared with Amdahl's law
                  S(p) = 1 / (s + (1 - s) / p)
  weak scaling:   scaled speedup = p * T(base) / T(p), compared with
                  Gustafson's law S(p) = p - s * (p - 1)

Here p = threads / threads_base and s is the serial fraction, obtained by a
least-squares fit to the median speedups. Error bars span the fastest and
slowest run at each thread count.
"""
import argparse
import sys
from dataclasses import dataclass
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

SURFACE = "#fcfcfb"
INK_PRIMARY = "#0b0b0b"
INK_SECONDARY = "#52514e"
GRIDLINE = "#e1e0d9"
BASELINE = "#c3c2b7"
IDEAL_COLOUR = "#898781"
MEASURED_COLOUR = "#2a78d6"
FIT_COLOUR = "#eb6834"
SMOOTH_POINT_COUNT = 200


@dataclass(frozen=True)
class RunStatistics:
    threads: np.ndarray
    relative_threads: np.ndarray
    run_count: int
    median: np.ndarray
    fastest: np.ndarray
    slowest: np.ndarray


@dataclass(frozen=True)
class Band:
    """A quantity with its central value and the range spanned by the runs."""

    centre: np.ndarray
    lower: np.ndarray
    upper: np.ndarray

    def times(self, factor: np.ndarray) -> "Band":
        return Band(self.centre * factor, self.lower * factor, self.upper * factor)


def load_statistics(path: Path) -> RunStatistics:
    table = np.loadtxt(path, delimiter=",", skiprows=1, ndmin=2)
    if table.shape[0] < 2 or table.shape[1] < 2:
        raise ValueError(f"{path}: need at least two thread counts and one run")
    table = table[np.argsort(table[:, 0])]
    threads = table[:, 0]
    runs = table[:, 1:]
    return RunStatistics(
        threads=threads,
        relative_threads=threads / threads[0],
        run_count=runs.shape[1],
        median=np.median(runs, axis=1),
        fastest=runs.min(axis=1),
        slowest=runs.max(axis=1),
    )


def baseline_over_time(stats: RunStatistics) -> Band:
    baseline = stats.median[0]
    return Band(baseline / stats.median, baseline / stats.slowest, baseline / stats.fastest)


def fit_amdahl(relative_threads: np.ndarray, speedup: np.ndarray) -> float:
    # 1/S - 1/p = s * (1 - 1/p) is linear in s
    regressor = 1.0 - 1.0 / relative_threads
    target = 1.0 / speedup - 1.0 / relative_threads
    return clamp_fraction(np.sum(regressor * target) / np.sum(regressor**2))


def fit_gustafson(relative_threads: np.ndarray, scaled_speedup: np.ndarray) -> float:
    # p - S = s * (p - 1) is linear in s
    regressor = relative_threads - 1.0
    target = relative_threads - scaled_speedup
    return clamp_fraction(np.sum(regressor * target) / np.sum(regressor**2))


def clamp_fraction(fraction: float) -> float:
    return float(min(max(fraction, 0.0), 1.0))


def amdahl_speedup(relative_threads: np.ndarray, serial_fraction: float) -> np.ndarray:
    return 1.0 / (serial_fraction + (1.0 - serial_fraction) / relative_threads)


def gustafson_speedup(relative_threads: np.ndarray, serial_fraction: float) -> np.ndarray:
    return relative_threads - serial_fraction * (relative_threads - 1.0)


def style_axes(axes: plt.Axes) -> None:
    axes.set_facecolor(SURFACE)
    axes.grid(axis="y", color=GRIDLINE, linewidth=0.8)
    axes.set_axisbelow(True)
    for side in ("top", "right"):
        axes.spines[side].set_visible(False)
    for side in ("left", "bottom"):
        axes.spines[side].set_color(BASELINE)
    axes.tick_params(colors=INK_SECONDARY)
    axes.xaxis.label.set_color(INK_SECONDARY)
    axes.yaxis.label.set_color(INK_SECONDARY)
    axes.title.set_color(INK_PRIMARY)


def draw_panel(
    axes: plt.Axes,
    stats: RunStatistics,
    measured: Band,
    ideal: np.ndarray,
    fit: np.ndarray,
    labels: dict,
) -> None:
    smooth_relative = smooth_range(stats)
    smooth_threads = smooth_relative * stats.threads[0]
    error = [measured.centre - measured.lower, measured.upper - measured.centre]
    axes.plot(smooth_threads, ideal, color=IDEAL_COLOUR, linewidth=1.5, linestyle="--", label="ideal")
    axes.plot(smooth_threads, fit, color=FIT_COLOUR, linewidth=2.0, label=labels["fit"])
    axes.errorbar(
        stats.threads,
        measured.centre,
        yerr=error,
        color=MEASURED_COLOUR,
        linewidth=2.0,
        marker="o",
        markersize=6,
        markeredgecolor=SURFACE,
        markeredgewidth=1.5,
        capsize=3,
        label=f"measured (median, min-max of {stats.run_count} runs)",
    )
    axes.set_title(labels["title"], loc="left", fontsize=12)
    axes.set_xlabel("threads")
    axes.set_ylabel(labels["ylabel"])
    axes.set_xticks(stats.threads)
    axes.set_xticklabels([f"{int(count)}" for count in stats.threads])
    axes.set_ylim(0.0, labels["ymax"])
    style_axes(axes)


def smooth_range(stats: RunStatistics) -> np.ndarray:
    return np.linspace(1.0, stats.relative_threads[-1], SMOOTH_POINT_COUNT)


def new_figure(title: str) -> tuple:
    figure, (speed_axes, efficiency_axes) = plt.subplots(
        1, 2, figsize=(11.0, 4.6), constrained_layout=True
    )
    figure.patch.set_facecolor(SURFACE)
    figure.suptitle(title, x=0.01, ha="left", fontsize=14, color=INK_PRIMARY)
    return figure, speed_axes, efficiency_axes


def upper_limit(bands: list, floor: float) -> float:
    return max(floor, 1.05 * max(np.max(band.upper) for band in bands))


def save_figure(figure: plt.Figure, speed_axes: plt.Axes, output_path: Path) -> None:
    legend = speed_axes.legend(loc="upper left", frameon=False, fontsize=9)
    for text in legend.get_texts():
        text.set_color(INK_SECONDARY)
    figure.savefig(output_path, dpi=200, facecolor=SURFACE)
    plt.close(figure)


def plot_strong(stats: RunStatistics, output_path: Path) -> float:
    speedup = baseline_over_time(stats)
    serial_fraction = fit_amdahl(stats.relative_threads, speedup.centre)
    smooth_relative = smooth_range(stats)
    amdahl = amdahl_speedup(smooth_relative, serial_fraction)
    efficiency = speedup.times(1.0 / stats.relative_threads)
    base = int(stats.threads[0])
    fit_label = f"Amdahl fit, serial fraction s = {serial_fraction:.3f}"

    figure, speed_axes, efficiency_axes = new_figure("Strong scaling (fixed problem size)")
    draw_panel(
        speed_axes, stats, speedup, smooth_relative, amdahl,
        {"title": "Speedup", "ylabel": f"T({base}) / T(p)", "fit": fit_label,
         "ymax": 1.05 * stats.relative_threads[-1]},
    )
    draw_panel(
        efficiency_axes, stats, efficiency, np.ones_like(smooth_relative), amdahl / smooth_relative,
        {"title": "Parallel efficiency", "ylabel": f"T({base}) / (p * T(p))", "fit": fit_label,
         "ymax": upper_limit([efficiency], floor=1.05)},
    )
    save_figure(figure, speed_axes, output_path)
    return serial_fraction


def plot_weak(stats: RunStatistics, output_path: Path) -> float:
    efficiency = baseline_over_time(stats)
    scaled_speedup = efficiency.times(stats.relative_threads)
    serial_fraction = fit_gustafson(stats.relative_threads, scaled_speedup.centre)
    smooth_relative = smooth_range(stats)
    gustafson = gustafson_speedup(smooth_relative, serial_fraction)
    base = int(stats.threads[0])
    fit_label = f"Gustafson fit, serial fraction s = {serial_fraction:.3f}"

    figure, speed_axes, efficiency_axes = new_figure("Weak scaling (constant work per thread)")
    draw_panel(
        speed_axes, stats, scaled_speedup, smooth_relative, gustafson,
        {"title": "Scaled speedup", "ylabel": f"p * T({base}) / T(p)", "fit": fit_label,
         "ymax": upper_limit([scaled_speedup], floor=1.05 * stats.relative_threads[-1])},
    )
    draw_panel(
        efficiency_axes, stats, efficiency, np.ones_like(smooth_relative), gustafson / smooth_relative,
        {"title": "Weak-scaling efficiency", "ylabel": f"T({base}) / T(p)", "fit": fit_label,
         "ymax": upper_limit([efficiency], floor=1.05)},
    )
    save_figure(figure, speed_axes, output_path)
    return serial_fraction


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--strong", type=Path, default=Path("strong-scaling.csv"))
    parser.add_argument("--weak", type=Path, default=Path("weak-scaling.csv"))
    parser.add_argument("--output-dir", type=Path, default=Path("."))
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    arguments.output_dir.mkdir(parents=True, exist_ok=True)
    jobs = [
        ("strong", arguments.strong, plot_strong, "strong-scaling.png"),
        ("weak", arguments.weak, plot_weak, "weak-scaling.png"),
    ]
    failure_count = 0
    for name, csv_path, plot, png_name in jobs:
        try:
            serial_fraction = plot(load_statistics(csv_path), arguments.output_dir / png_name)
        except (OSError, ValueError) as error:
            print(f"{name}: skipped, {error}", file=sys.stderr)
            failure_count += 1
            continue
        print(f"{name}: wrote {arguments.output_dir / png_name} (fitted serial fraction s = {serial_fraction:.3f})")
    return 1 if failure_count else 0


if __name__ == "__main__":
    sys.exit(main())
