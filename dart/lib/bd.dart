import 'dart:math';

import 'package:tuple/tuple.dart';

import "global.dart";
import "sets.dart";
import "dart:io";

class BD {
  static const int INFINITY_ = 2000000000;
  static int N = INFINITY_;
  static List<List<int>> solutionDepth;
  static List<List<int>> reachedLimit;

  /**
   * Compute the Barnes's upper bound [3].
   *
   * [3] F. W. Barnes. Packing the maximum number of m x n tiles in a
   *     large p x q rectangle. Discrete Mathematics, volume 26,
   *     pages 93-100, 1979.
   *
   * Parameters:
   * (L, W) Pallet dimensions.
   * (l, w) Dimensions of the boxes to be packed.
   *
   * Return:
   * - the computed Barnes's bound.
   */
  static int barnesBound(int L, int W, int l, int w) {
    int r, s, D;
    int minWaste = (L * W) % (l * w);

    /* (l,1)-boxes packing. */
    r = L % l;
    s = W % l;
    int A = min(r * s, (l - r) * (l - s));

    /* (1,w)-boxes packing. */
    r = L % w;
    s = W % w;
    int B = min(r * s, (w - r) * (w - s));

    /* Best unitary tile packing. */
    int maxAB = max(A, B);

    /* Wasted area. */
    if (minWaste >= maxAB % (l * w)) {
      D = (maxAB ~/ (l * w)) * (l * w) + minWaste;
    } else {
      D = (maxAB ~/ (l * w) + 1) * (l * w) + minWaste;
    }

    return (L * W - D) ~/ (l * w);
  }

  static int localUpperBound(int iX, int iY) {
    if (solutionDepth[iX][iY] == -1) {
      return Global.lowerBound[iX][iY];
    } else {
      return Global.upperBound[iX][iY];
    }
  }

  /**
   * Auxiliar function.
   *
   * Parameters:
   *
   * L - Length of the pallet.
   * W - Width of the pallet.
   * l - Length of the boxes.
   * w - Width of the boxes.
   * n - Maximum search depth.
   *
   * numBlocks - Number of blocks in the current division of the pallet.
   *
   * L_, W_ - Lenghts and widths for each partition of the pallet.
   *
   * z_lb   - Current lower bound for (L,W).
   * z_ub   - Upper bound for (L,W).
   *
   * x1, x2, y1, y2 - Points that determine the division of the pallet.
   *
   * Return:
   * - the number of (l,w)-boxes packed into (L,W) pallet, using the
   *   division determined by (x1,x2,y1,y2).
   */
  static Tuple2<bool, int> solve(
      int L,
      int W,
      int l,
      int w,
      int n,
      int numBlocks,
      List<int> L_,
      List<int> W_,
      int z_lb,
      int z_ub,
      int x1,
      int x2,
      int y1,
      int y2) {
    /* z[1..5] stores the amount of boxes packed into partitions 1 to 5. */
    List<int> z = new List<int>(6);

    /* Sum of the lower and upper bounds for the number of boxes that
    * can be packed into partitions 1 to 5. */
    int S_lb, S_ub;

    /* Indices of the subproblems in the indexing matrices. */
    List<int> iX = new List<int>(6), iY = new List<int>(6);

    /* Lower and upper bounds for each partition. */
    List<int> zi_ub = new List<int>(6), zi_lb = List<int>(6);

    int i;

    /* Normalize each rectangle produced. */
    for (i = 1; i <= numBlocks; i++) {
      /* Normalize the size of the rectangle (Li,Wi). */
      L_[i] = Global.normalize[L_[i]];
      W_[i] = Global.normalize[W_[i]];

      /* We assume that Li >= Wi. */
      if (L_[i] < W_[i]) {
        int tmp = L_[i];
        L_[i] = W_[i];
        W_[i] = tmp;
      }

      /* Get the indices of each subproblem in the indexing matrices. */
      iX[i] = Global.indexX[L_[i]];
      iY[i] = Global.indexY[W_[i]];
    }

    /* If maximum level of the recursion was not reached. */
    if (n < N) {
      /* Store the sum of best packing estimations in the 5 partitions
      * until this moment. Initially, it receives the sum of the lower
      * bounds. */
      S_lb = 0;

      /* Sum of the upper bounds in the 5 partitions. */
      S_ub = 0;

      /* Compute the lower (zi_lb) and upper (zi_ub) bounds of each
      * partition. */
      for (i = 1; i <= numBlocks; i++) {
        /* Lower bound of (Li, Wi). */
        zi_lb[i] = Global.lowerBound[iX[i]][iY[i]];
        S_lb += zi_lb[i];
        /* Upper bound of (Li, Wi). */
        zi_ub[i] = localUpperBound(iX[i], iY[i]);
        S_ub += zi_ub[i];
      }

      if (z_lb < S_ub) {
        /* The current lower bound is less than the sum of the partitions
        * upper bounds. Then, there is a possibility of this division
        * improve the solution. */

        for (i = 1; i <= numBlocks; i++) {
          if (solutionDepth[iX[i]][iY[i]] > n) {
            /* Solve for the first time or give another chance for
            * this problem. */
            z[i] = do_BD(L_[i], W_[i], l, w, n + 1);
            Global.lowerBound[iX[i]][iY[i]] = z[i];

            if (reachedLimit[iX[i]][iY[i]] == 0) {
              solutionDepth[iX[i]][iY[i]] = -1;
            } else {
              solutionDepth[iX[i]][iY[i]] = n;
            }
          } else {
            /* This problem was already solved. It gets the
            * solution obtained previously. */
            z[i] = Global.lowerBound[iX[i]][iY[i]];
          }

          if (reachedLimit[iX[i]][iY[i]] == 1) {
            reachedLimit[Global.indexX[L]][Global.indexY[W]] = 1;
          }

          /* Update lower and upper bounds for this partitioning. */
          S_lb = S_lb - zi_lb[i] + z[i];
          S_ub = S_ub - zi_ub[i] + z[i];

          /* If z_lb >= S_ub, we have, at least, a solution as good as
          * the one that can be find with this partitioning. So this
          * partitioning is discarded. */
          if (z_lb >= S_ub) {
            break;
          }

          /* If the sum of packings in the current partitions is better
          * than the previous, update the lower bound. */
          else if (S_lb > z_lb) {
            z_lb = S_lb;
            storeCutPoint(L, W, x1, x2, y1, y2);
            if (z_lb == z_ub) {
              /* An optimal solution was found. */
              solutionDepth[Global.indexX[L]][Global.indexY[W]] = -1;
              reachedLimit[Global.indexX[L]][Global.indexY[W]] = 0;
              return new Tuple2<bool, int>(true, z_lb);
            }
          }
        }
      }
    } /* if n < N */

    /* The maximum depth of recursion was reached. Then, each partition
    * will not be solved recursivelly. Each one receives the best
    * packing obtained until this moment. */
    else {
      reachedLimit[Global.indexX[L]][Global.indexY[W]] = 1;
      S_lb = 0;

      /* Compute the lower bound of each partition and the sum is
      * stored in S_lb. */
      for (i = 1; i <= numBlocks; i++) {
        S_lb += Global.lowerBound[iX[i]][iY[i]];
      }

      /* If the sum of the homogeneous packing in all current
      * partitions is better than the previous estimation for (L,W),
      * update the lower bound. */
      if (S_lb > z_lb) {
        z_lb = S_lb;
        storeCutPoint(L, W, x1, x2, y1, y2);
        if (z_lb == z_ub) {
          /* An optimal solution was found. */
          solutionDepth[Global.indexX[L]][Global.indexY[W]] = -1;
          reachedLimit[Global.indexX[L]][Global.indexY[W]] = 0;
          return new Tuple2<bool, int>(true, z_lb);
        }
      }
    }

    return new Tuple2<bool, int>(false, z_lb);
  }

  /**
   * Store the points x1, x2, y1 and y2 that determine the cut in the
   * rectangle (L,W).
   */
  static void storeCutPoint(int L, int W, int x1, int x2, int y1, int y2) {
    Global.cutPoints[Global.indexX[L]][Global.indexY[W]] =
        new CutPoint(x1, x2, y1, y2, 0);
  }

  /**
   * Guillotine and first order non-guillotine cuts recursive procedure.
   *
   * Parameters:
   * L - Length of the pallet.
   * W - Width of the pallet.
   * l - Length of the boxes.
   * w - Width of the boxes.
   * n - Maximum search depth.
   *
   * Return:
   * - the number of (l,w)-boxes packed into (L,W) pallet.
   */
  static int do_BD(int L, int W, int l, int w, int n) {
    /* Lower and upper bounds for the number of (l,w)-boxes that can be
    * packed into (L,W). */
    int z_lb, z_ub;

    /* We assume that L >= W. */
    if (W > L) {
      int tmp = L;
      L = W;
      W = tmp;
    }

    z_lb = Global.lowerBound[Global.indexX[L]][Global.indexY[W]];
    z_ub = localUpperBound(Global.indexX[L], Global.indexY[W]);

    if (z_lb == 0 || z_lb == z_ub) {
      /* An optimal solution was found: no box fits into the pallet or
      * lower and upper bounds are equal. */
      solutionDepth[Global.indexX[L]][Global.indexY[W]] = -1;
      reachedLimit[Global.indexX[L]][Global.indexY[W]] = 0;
      return z_lb;
    } else {
      /* Points that determine the pallet division. */
      int x1, x2, y1, y2;

      /* Indices of x1, x2, y1 and y2 in the raster points arrays. */
      int index_x1, index_x2, index_y1, index_y2;

      /* Size of the generated partitions:
      * (L_[i], W_[i]) is the size of the partition i, for i = 1, ..., 5. */
      List<int> L_ = new List<int>(6), W_ = new List<int>(6);

      /* Construct the raster points sets. */
      Tuple2<Set, Set> rasterTuple =
          Global.normalSetX.constructRasterPoints(L, W);
      Set rasterX = rasterTuple.item1, rasterY = rasterTuple.item2;

      reachedLimit[Global.indexX[L]][Global.indexY[W]] = 0;

      /*
      * Loop to generate the cut points (x1, x2, y1 and y2) considering
      * the following symmetries.
      *
      * - First order non-guillotine cuts:
      *   0 < x1 < x2 < L and 0 < y1 < y2 < W
      *   (x1 + x2 < L) or (x1 + x2 = L and y1 + y2 <= W)
      *
      * - Vertical guillotine cuts:
      *   0 < x1 = x2 <= L/2 and y1 = y2 = 0
      *
      * - Horizontal guillotine cuts:
      *   0 < y1 = y2 <= W/2 and x1 = x2 = 0
      *
      * Observation: In the loop of non-guillotine cuts it can appear less
      * than five partitions in the case of the normalization of a side
      * of a partition be zero.
      */

      /*#################################*
      * First order non-guillotine cuts *
      *#################################*/

      /*
          L_1     L_2
          ----------------
        |     |    2     |W_2
      W_1|  1  |          |
        |     |----------|
        |     | 3 |      |
        |---------|      |
        |         |  5   |W_5
      W_4|    4    |      |
        |         |      |
          ----------------
            L_4     L_5
      */

      for (index_x1 = 1;
          index_x1 < rasterX.size && rasterX.points[index_x1] <= L ~/ 2;
          index_x1++) {
        x1 = rasterX.points[index_x1];

        for (index_x2 = index_x1 + 1;
            index_x2 < rasterX.size && rasterX.points[index_x2] + x1 <= L;
            index_x2++) {
          x2 = rasterX.points[index_x2];

          for (index_y1 = 1;
              index_y1 < rasterY.size && rasterY.points[index_y1] < W;
              index_y1++) {
            y1 = rasterY.points[index_y1];

            for (index_y2 = index_y1 + 1;
                index_y2 < rasterY.size && rasterY.points[index_y2] < W;
                index_y2++) {
              y2 = rasterY.points[index_y2];

              /* Symmetry. When x1 + x2 = L, we can restrict y1 and y2
              * to y1 + y2 <= W. */
              if (x1 + x2 == L && y1 + y2 > W) break;

              /* The five partitions. */
              L_[1] = x1;
              W_[1] = W - y1;

              L_[2] = L - x1;
              W_[2] = W - y2;

              L_[3] = x2 - x1;
              W_[3] = y2 - y1;

              L_[4] = x2;
              W_[4] = y1;

              L_[5] = L - x2;
              W_[5] = y2;

              Tuple2<bool, int> solved =
                  solve(L, W, l, w, n, 5, L_, W_, z_lb, z_ub, x1, x2, y1, y2);
              z_lb = solved.item2; // Used as a kind of pointer

              if (solved.item1) {
                /* This problem was solved with optimality guarantee. */
                return z_lb;
              }
            } /* for y2 */
          } /* for y1 */
        } /* for x2 */
      } /* for x1 */

      /*###########################*
      * Vertical guillotine cuts. *
      *###########################*/

      /*
        ----------------
        |     |          |
        |     |          |
        |     |          |
        |  1  |    2     |
        |     |          |
        |     |          |
        |     |          |
        |     |          |
        ----------------
      */

      for (index_x1 = 1;
          index_x1 < rasterX.size && rasterX.points[index_x1] <= L / 2;
          index_x1++) {
        x1 = x2 = rasterX.points[index_x1];
        y1 = y2 = 0;

        /* Partitions 1 and 2 generated by the vertical cut. */
        L_[1] = x1;
        W_[1] = W - y1;

        L_[2] = L - x1;
        W_[2] = W - y2;

        Tuple2<bool, int> solved =
            solve(L, W, l, w, n, 2, L_, W_, z_lb, z_ub, x1, x2, y1, y2);
        z_lb = solved.item2; // Used as a kind of pointer

        if (solved.item1) {
          /* This problem was solved with optimality guarantee. */
          return z_lb;
        }
      }

      /*#############################*
      * Horizontal guillotine cuts. *
      *#############################*/

      /*
        ----------------
        |       2        |
        |                |
        |----------------|
        |                |
        |                |
        |       5        |
        |                |
        |                |
        ----------------
      */

      for (index_y1 = 1;
          index_y1 < rasterY.size && rasterY.points[index_y1] <= W / 2;
          index_y1++) {
        y1 = y2 = rasterY.points[index_y1];
        x1 = x2 = 0;

        /* Partitions 2 and 5 generated by the horizontal cut. */
        L_[1] = L - x1;
        W_[1] = W - y2;

        L_[2] = L - x2;
        W_[2] = y2;

        Tuple2<bool, int> solved =
            solve(L, W, l, w, n, 2, L_, W_, z_lb, z_ub, x1, x2, y1, y2);
        z_lb = solved.item2; // Used as a kind of pointer

        if (solved.item1) {
          /* This problem was solved with optimality guarantee. */
          return z_lb;
        }
      }

      return z_lb;
    }
  }

  static void initialize(int L, int W, int l, int w) {
    /* Normalization of L and W. */
    int L_n, W_n;

    int i, j;

    /* Construct the conic combination set of l and w. */
    Global.normalSetX = new Set();
    Global.normalSetX.constructConicCombinations(L, l, w);

    /* Compute the values of L* and W*.
    * normalize[i] = max {x in X | x <= i} */
    Global.normalize = new List<int>(L + 1);
    i = 0;
    for (int j = 0; j <= L; j++) {
      for (;
          i < Global.normalSetX.size && Global.normalSetX.points[i] <= j;
          i++) {}

      Global.normalize[j] = Global.normalSetX.points[i - 1];
    }

    /* Normalize (L, W). */
    L_n = Global.normalize[L];
    W_n = Global.normalize[W];

    Tuple2<Set, Set> rasterTuple =
        Global.normalSetX.constructRasterPoints(L, W);
    Set rasterX = rasterTuple.item1, rasterY = rasterTuple.item2;

    Global.normalSetX = new Set();
    i = 0;
    j = 0;
    while (i < rasterX.size &&
        rasterX.points[i] <= L_n &&
        j < rasterY.size &&
        rasterY.points[j] <= W_n) {
      if (rasterX.points[i] == rasterY.points[j]) {
        Global.normalSetX.points.add(rasterX.points[i++]);
        j++;
      } else if (rasterX.points[i] < rasterY.points[j]) {
        Global.normalSetX.points.add(rasterX.points[i++]);
      } else {
        Global.normalSetX.points.add(rasterY.points[j++]);
      }
    }
    while (i < rasterX.size && rasterX.points[i] <= L_n) {
      if (rasterX.points[i] > Global.normalSetX.points.last) {
        Global.normalSetX.points.add(rasterX.points[i]);
      }
      i++;
    }
    if (Global.normalSetX.points.length > 0 &&
        Global.normalSetX.points.last < L_n) {
      Global.normalSetX.points.add(L_n);
    }
    Global.normalSetX.points.add(L_n + 1);

    /* Construct the array of indices. */
    Global.indexX = new List<int>(L_n + 2);
    Global.indexY = new List<int>(W_n + 2);

    for (i = 0; i < Global.normalSetX.size; i++) {
      Global.indexX[Global.normalSetX.points[i]] = i;
    }

    int ySize = 0;
    for (i = 0; i < Global.normalSetX.size; i++) {
      if (Global.normalSetX.points[i] > W_n) {
        break;
      }
      ySize++;
      Global.indexY[Global.normalSetX.points[i]] = i;
    }

    BD.solutionDepth = new List<List<int>>(Global.normalSetX.size);
    Global.upperBound = new List<List<int>>(Global.normalSetX.size);
    Global.lowerBound = List<List<int>>(Global.normalSetX.size);
    BD.reachedLimit = new List<List<int>>(Global.normalSetX.size);
    Global.cutPoints = new List<List<CutPoint>>(Global.normalSetX.size);

    for (i = 0; i < Global.normalSetX.size; i++) {
      BD.solutionDepth[i] = new List<int>(ySize);
      Global.upperBound[i] = new List<int>(ySize);
      Global.lowerBound[i] = new List<int>(ySize);
      Global.cutPoints[i] = new List<CutPoint>(ySize);
      BD.reachedLimit[i] = new List<int>(ySize);
    }

    for (i = 0; i < Global.normalSetX.size; i++) {
      int x = Global.normalSetX.points[i];

      for (j = 0; j < ySize; j++) {
        int y = Global.normalSetX.points[j];

        BD.solutionDepth[i][j] = BD.N;
        BD.reachedLimit[i][j] = 1;
        Global.upperBound[i][j] = BD.barnesBound(x, y, l, w);
        Global.lowerBound[i][j] = max((x ~/ l) * (y ~/ w), (x ~/ w) * (y ~/ l));
        Global.cutPoints[i][j] = new CutPoint.zeroed(1);
      }
    }
  }

  /**
   * Parameters:
   * L     - Length of the pallet.
   * W     - Width of the pallet.
   * l     - Length of the boxes.
   * w     - Width of the boxes.
   * N_max - Maximum depth.
   */
  static int solve_BD(int L, int W, int l, int w, int N_max) {
    int L_n, W_n;

    BD.N = N_max;
    if (N <= 0) N = INFINITY_;

    /* We assume that L >= W. */
    if (W > L) {
      int tmp = L;
      L = W;
      W = tmp;
    }

    BD.initialize(L, W, l, w);

    /* Normalize (L, W). */
    L_n = Global.normalize[L];
    W_n = Global.normalize[W];

    int solution = do_BD(L_n, W_n, l, w, N);

    if (solution != Global.upperBound[Global.indexX[L_n]][Global.indexY[W_n]] && N != 1)
    {
      /* If the solution found is not optimal (or, at least, if it is not
      * possible to prove its optimality), solve from the first level. */
      solution = do_BD(L_n, W_n, l, w, 1);
    }

    Global.lowerBound[Global.indexX[L_n]][Global.indexY[W_n]] = solution;

    return solution;
  }
}
