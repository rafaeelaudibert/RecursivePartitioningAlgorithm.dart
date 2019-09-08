import 'dart:io';
import 'dart:math';

import "draw.dart";
import "global.dart";
import "bd.dart";
import "sets.dart";
import 'package:tuple/tuple.dart';

class Main {
  static int roundToNearest(double a) => (a + 0.5).floor();

  /**
   * Calculate the upper bound of a given rectangle R(x,y) (degenerated L).
   *
   * Parameters:
   * x - Length of the rectangle.
   *
   * y - Width of the rectangle.
   *
   * Return:
   * The computed upper bound.
   */
  static int R_UpperBound(int x, int y) {
    /* A(R) / lw */
    x = Global.normalize[x];
    y = Global.normalize[y];
    return Global.upperBound[Global.indexX[x]][Global.indexY[y]];
  }

  /**
   * Calculate the upper bound of a given L.
   *
   * Parameters:
   * q - The L-piece.
   *
   * Return:
   * The computed upper bound for this L-piece.
   */
  static int L_UpperBound(List<int> q) {
    return ((q[0] * q[1] - (q[0] - q[2]) * (q[1] - q[3])) /
            (Global.l * Global.w))
        .round();
  }

  /**
   * Calculate the lower bound of a given rectangle R(x,y) (degenerated L).
   *
   * Parameters:
   * x - Length of the rectangle.
   *
   * y - Width of the rectangle.
   *
   * Return:
   * The computed lower bound.
   */
  int R_LowerBound(int x, int y) {
    x = Global.normalize[x];
    y = Global.normalize[y];
    return Global.lowerBound[Global.indexX[x]][Global.indexY[y]];
  }

  /**
   * Calculate the lower bound of a given L. It divides the L in two
   * rectangles and calculates their lower bounds to compose the lower
   * bound of the L-piece.
   *
   * +-----+              +-----+              +-----+
   * |     |              |     |              |     |
   * |     |              |     |              |     |
   * |     +----+   -->   +-----+----+    or   |     +----+
   * |          |         |          |         |     |    |
   * |          |         |          |         |     |    |
   * +----------+         +----------+         +-----+----+
   *                           (a)                  (b)
   *
   * Parameters:
   * q - The L-piece.
   *
   * Return:
   * The computed lower bound.
   */
  Tuple2<int, bool> L_LowerBound(List<int> q) {
    int a = Global.lowerBound[Global.indexX[Global.normalize[q[2]]]]
            [Global.indexY[Global.normalize[q[1] - q[3]]]] +
        Global.lowerBound[Global.indexX[Global.normalize[q[0]]]]
            [Global.indexY[Global.normalize[q[3]]]];

    int b = Global.lowerBound[Global.indexX[Global.normalize[q[2]]]]
            [Global.indexY[Global.normalize[q[1]]]] +
        Global.lowerBound[Global.indexX[Global.normalize[q[0] - q[2]]]]
            [Global.indexY[Global.normalize[q[3]]]];

    if (a > b) return Tuple2(a, true);
    return Tuple2(b, false);
  }

  /**
   * Divide an L-piece in two new L-pieces, according to the specified
   * subdivision, and normalize the two ones.
   *
   * Parameters:
   * i  - Point that determines the division int the L-piece.
   *
   * q  - The L-piece to be divided.
   *
   * q1 - It will store a new L-piece.
   *
   * q2 - It will store the other new L-piece.
   *
   * standardPosition - Pointer to the function that will divide the L-piece.
   */
  /*void divide(List<int> i, List<int> q, List<int> q1, List<int> q2,
      Function standardPosition) {
    /* Divide the L-piece in two new ones. */
    standardPosition(i, q, q1, q2);

    /* Normalize the new L-pieces. */
    normalizePiece(q1);
    normalizePiece(q2);
  }*/

  static void makeIndices(int L, int W) {
    Tuple2<Set, Set> rasterTuple =
        Global.normalSetX.constructRasterPoints(L, W);
    Set X = rasterTuple.item1, Y = rasterTuple.item2;

    int j = 0;
    int k = 0;
    int i = 0;

    Set raster = new Set();
    while (i < X.size && X.points[i] <= L && j < Y.size && Y.points[j] <= W) {
      if (X.points[i] == Y.points[j]) {
        raster.points.add(X.points[i++]);
        j++;
      } else if (X.points[i] < Y.points[j]) {
        raster.points.add(X.points[i++]);
      } else {
        raster.points.add(Y.points[j++]);
      }
    }

    while (i < X.size && X.points[i] <= L) {
      if (X.points[i] > raster.points.last) {
        raster.points.add(X.points[i]);
      }
      i++;
    }
    if (raster.points.length > 0 && raster.points.last < L) {
      raster.points.add(L);
    }

    raster.points.add(L + 1);

    Global.indexRasterX = new List<int>(L + 2);
    Global.indexRasterY = new List<int>(W + 2);

    j = 0;
    Global.numRasterX = 0;
    for (int i = 0; i <= L; i++) {
      if (raster.points[j] == i) {
        Global.indexRasterX[i] = Global.numRasterX++;
        j++;
      } else {
        Global.indexRasterX[i] = Global.indexRasterX[i - 1];
      }
    }
    Global.indexRasterX[L + 1] = Global.indexRasterX[L] + 1;

    j = 0;
    Global.numRasterY = 0;
    for (int i = 0; i <= W; i++) {
      if (raster.points[j] == i) {
        Global.indexRasterY[i] = Global.numRasterY++;
        j++;
      } else {
        Global.indexRasterY[i] = Global.indexRasterY[i - 1];
      }
    }
    Global.indexRasterY[W + 1] = Global.indexRasterY[W] + 1;
  }

  static bool tryAllocateMemory(int size) {
    try {
      Global.solutionMap = new List<Map>(size);
    } catch (Exception) {
      if (size == 0) {
        print("Error allocating memory.");
        exit(0);
      }
      return false;
    }

    try {
      Global.divisionPointMap = new List<Map>(size);
    } catch (Exception) {
      Global.solutionMap = null;
      Global.divisionPointMap = null;
      if (size == 0) {
        print("Error allocating memory.");
        exit(0);
      }
      return false;
    }

    return true;
  }

  static void allocateMemory() {
    Global.memory_type = MemType.TYPE4;

    int nL = roundToNearest(
        (pow(Global.numRasterX, (Global.memory_type.index / 2.0).ceil()) *
            pow(Global.numRasterY, (Global.memory_type.index / 2.0).floor())));

    // memory_type--;
    Global.memory_type = MemType.values[Global.memory_type.index - 1];

    if (nL >= 0) {
      try {
        Global.solution = new List<int>(nL);
        try {
          Global.divisionPoint = new List<int>(nL);
          for (int i = 0; i < nL; i++) Global.solution[i] = -1;
        } catch (Exception) {
          Global.solution = null; // delete[] solution;
          do {
            nL = roundToNearest((pow(Global.numRasterX,
                    (Global.memory_type.index / 2.0).ceil()) *
                pow(Global.numRasterY,
                    (Global.memory_type.index / 2.0).floor())));

            // memory_type--;
            Global.memory_type = MemType.values[Global.memory_type.index - 1];

            if (nL >= 0 && tryAllocateMemory(nL)) {
              break;
            }
          } while (Global.memory_type.index >= 0);
        }
      } catch (Exception) {
        do {
          nL = roundToNearest(
              (pow(Global.numRasterX, (Global.memory_type.index / 2.0).ceil()) *
                  pow(Global.numRasterY,
                      (Global.memory_type.index / 2.0).floor())));

          // memory_type--;
          Global.memory_type = MemType.values[Global.memory_type.index - 1];

          if (nL >= 0 && tryAllocateMemory(nL)) {
            break;
          }
        } while (Global.memory_type.index >= 0);
      }
    } else {
      do {
        nL = roundToNearest((pow(
                Global.numRasterX, (Global.memory_type.index / 2.0).ceil()) *
            pow(Global.numRasterY, (Global.memory_type.index / 2.0).floor())));

        // memory_type--;
        Global.memory_type = MemType.values[Global.memory_type.index - 1];

        if (nL >= 0 && tryAllocateMemory(nL)) {
          break;
        }
      } while (Global.memory_type.index >= 0);
    }

    // memory_type++;
    Global.memory_type = MemType.values[Global.memory_type.index + 1];
  }

  static void main() {
    int L, W;
    List<int> q = new List<int>(4);
    int BD_solution, L_solution;
    int INDEX;
    int L_n, W_n;

    // Will get L and W as parameter, but hardcoding right now
    L = 30;
    W = 30;

    // Will get l and w as parameter but hardcoding right now
    Global.l = 4;
    Global.w = 6;

    if (L < W) {
      int tmp = L;
      L = W;
      W = tmp;
    }

    Global.memory_type = MemType.TYPE4;

    /* Try to solve the problem with Algorithm 1. */
    BD_solution = BD.solve_BD(L, W, Global.l, Global.w, 0);

    print("\nPhase 1 (Five-block Algorithm)");
    print(" - solution found: $BD_solution box(es)");

    L_solution = -1;

    L_n = Global.normalize[L];
    W_n = Global.normalize[W];

    if (BD_solution !=
        Global.upperBound[Global.indexX[L_n]][Global.indexY[W_n]]) {
      throw Exception("Not implemented L-algorithm yet");
      /* The solution obtained by Algorithm 1 is not known to be
      * optimal. Then it will try to solve the problem with
      * L-Algorithm. */

      /*makeIndices(L_n, W_n);
      allocateMemory();

      q[0] = q[2] = L_n;
      q[1] = q[3] = W_n;

      INDEX = LIndex(q[0], q[1], q[2], q[3], memory_type);
      solve(INDEX, q);
      L_solution = getSolution(INDEX, q);

      draw(L, W, INDEX, q, L_solution & nRet, true);
      freeMemory();

      // getrusage(RUSAGE_SELF, &usage);

      /* L_time = (((double)usage.ru_utime.tv_sec +
                ((double)usage.ru_utime.tv_usec / 1e06)) -
                ((double)prev_usage.ru_utime.tv_sec +
                ((double)prev_usage.ru_utime.tv_usec / 1e06)));
      */

      printf("\nPhase 2 (L-Algorithm)\n");
      printf(" - solution found: %d box", L_solution);
      if (L_solution >= 2) {
        printf("es");
      }
      printf(".\n");
      // printf(" - runtime:        %.2f second", L_time);
      // if (L_time >= 2.0)
      // {
      //   printf("s");
      // }
      printf("\n");
      */
    } else {
      q[0] = q[2] = L_n;
      q[1] = q[3] = W_n;
      // draw(L, W, 0, q, BD_solution, false);
    }

    // makeGraphics();

    int n = max(BD_solution, L_solution);
    print("Solution found: $n box(es)");

    int upper = Global.upperBound[Global.indexX[L_n]][Global.indexY[W_n]];
    print("Computed upper bound: $upper box(es)");

    if (upper == n) {
      print("Proven optimal solution.");
    }

    return;
  }
}

void main() {
  return Main.main();
}
