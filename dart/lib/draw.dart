import 'package:tuple/tuple.dart';

import 'util.dart';
import 'global.dart';

enum CutDirection { HORIZONTAL, VERTICAL }
enum MemType { TYPE1, TYPE2, TYPE3, TYPE4 }

class Draw {
  // Default constructor
  Draw() {}

  static int ret;
  static List<List<int>> ptoRet;

  static int LIndex(int q0, int q1, int q2, int q3) {
    return Util.LIndex(q0, q1, q2, q3, Global.memory_type);
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
   * The lower bound.
   */
  static int R_LowerBound(int x, int y) {
    x = Global.normalize[x];
    y = Global.normalize[y];
    return Global.lowerBound[Global.indexX[x]][Global.indexY[y]];
  }

  /**
   * Determine how to cut the L-piece.
   *
   * Parameter:
   * q - The L-piece.
   */
  static CutDirection LCut(List<int> q) {
    // Divide the L-piece in two rectangles and calculate their lower
    // bounds to compose the lower bound of the L-piece.
    int a = R_LowerBound(q[2], q[1]) + R_LowerBound(q[0] - q[2], q[3]);
    int b = R_LowerBound(q[2], q[1] - q[3]) + R_LowerBound(q[0], q[3]);

    return a > b ? CutDirection.VERTICAL : CutDirection.HORIZONTAL;
  }

  /**
   * Fix the coordinates of the rectangle with the specified identifier.
   *
   * Paremeter:
   * id - Identifier of the rectangle.
   */
  static void fixCoordinates(int id) {
    if (ptoRet[id][0] > ptoRet[id][2]) {
      var tmp = ptoRet[id][0];
      ptoRet[id][0] = ptoRet[id][2];
      ptoRet[id][2] = tmp;
    }

    if (ptoRet[id][1] > ptoRet[id][3]) {
      var tmp = ptoRet[id][1];
      ptoRet[id][1] = ptoRet[id][1];
      ptoRet[id][3] = tmp;
    }
  }

  /**
   * Normalize degenerated L-pieces.
   *
   * Parameter:
   * q - The degenerated L-piece to be normalized.
   */
  static void normalizeDegeneratedL(List<int> q) {
    if (q[2] == 0) {
      q[2] = q[0];
      q[1] = q[3];
    } else if (q[3] == 0) {
      q[3] = q[1];
      q[0] = q[2];
    } else if (q[2] == q[0] || q[3] == q[1]) {
      q[2] = q[0];
      q[3] = q[1];
    }
  }

  /**
   * Shift the rectangle in the x-axis.
   *
   * Paremeters:
   * id     - Identifier of the rectangle.
   *
   * deltaX - Amount to be shifted.
   */
  static void shiftX(int id, int deltaX) {
    ptoRet[id][0] += deltaX;
    ptoRet[id][2] += deltaX;
  }

  /**
 * Shift the rectangle in the y-axis.
 *
 * Paremeters:
 * id     - Identifier of the rectangle.
 *
 * deltaY - Amount to be shifted.
 */
  static void shiftY(int id, int deltaY) {
    ptoRet[id][1] += deltaY;
    ptoRet[id][3] += deltaY;
  }

  // ******************************************************************

  static void P1(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      ptoRet[i][1] = q[1] - ptoRet[i][1];
      ptoRet[i][3] = q[1] - ptoRet[i][3];

      fixCoordinates(i);

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P2(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      ptoRet[i][0] = q[0] - ptoRet[i][0];
      ptoRet[i][2] = q[0] - ptoRet[i][2];

      fixCoordinates(i);

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P3(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      ptoRet[i][0] = q[0] - ptoRet[i][0];
      ptoRet[i][2] = q[0] - ptoRet[i][2];

      ptoRet[i][1] = q[1] - ptoRet[i][1];
      ptoRet[i][3] = q[1] - ptoRet[i][3];

      fixCoordinates(i);

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P4(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P5(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      int tmp1 = ptoRet[i][1];
      int tmp2 = ptoRet[i][3];

      ptoRet[i][1] = q[0] - ptoRet[i][0];
      ptoRet[i][3] = q[0] - ptoRet[i][2];

      ptoRet[i][0] = tmp1;
      ptoRet[i][2] = tmp2;

      fixCoordinates(i);

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P6(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      int tmp1 = ptoRet[i][0];
      int tmp2 = ptoRet[i][2];

      ptoRet[i][0] = q[1] - ptoRet[i][1];
      ptoRet[i][2] = q[1] - ptoRet[i][3];

      ptoRet[i][1] = tmp1;
      ptoRet[i][3] = tmp2;

      fixCoordinates(i);

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P7(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      int tmp1 = q[0] - ptoRet[i][0];
      int tmp2 = q[0] - ptoRet[i][2];

      ptoRet[i][0] = q[1] - ptoRet[i][1];
      ptoRet[i][2] = q[1] - ptoRet[i][3];

      ptoRet[i][1] = tmp1;
      ptoRet[i][3] = tmp2;

      fixCoordinates(i);

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  static void P8(
      int start, int end, int L, List<int> q, int deltaX, int deltaY) {
    for (int i = start; i < end; i++) {
      int tmp1 = ptoRet[i][0];
      int tmp2 = ptoRet[i][2];

      ptoRet[i][0] = ptoRet[i][1];
      ptoRet[i][2] = ptoRet[i][3];

      ptoRet[i][1] = tmp1;
      ptoRet[i][3] = tmp2;

      shiftX(i, deltaX);
      shiftY(i, deltaY);
    }
  }

  /**
 * Draw the boxes according to the B1 subdivision.
 */
  void drawB1(int L, List<int> q) {
    int L1, L2;
    List<int> q1 = new List<int>(4),
        q2 = new List<int>(4),
        tmp = new List<int>(4);
    int width, height;
    int deltaX, deltaY;
    int start, end;
    List<int> div = new List<int>(2);

    if (Global.memory_type == MemType.TYPE4) {
      div[0] = Global.divisionPoint[L] & Util.ptoDiv1;
      div[1] = (Global.divisionPoint[L] & Util.ptoDiv2) >> Util.descPtoDiv2;
    } else {
      int h = Util.getKey(q[0], q[1], q[2], q[3], Global.memory_type);
      div[0] = Global.divisionPointMap[L][h] & Util.ptoDiv1;
      div[1] =
          (Global.divisionPointMap[L][h] & Util.ptoDiv2) >> Util.descPtoDiv2;
    }

    Util.standardPositionB1(div, q, q1, q2);

    /* Draw L1. */
    tmp[0] = q1[0];
    tmp[1] = q1[1];
    tmp[2] = q1[2];
    tmp[3] = q1[3];
    normalizeDegeneratedL(tmp);

    Util.normalizePiece(q1);
    L1 = LIndex(q1[0], q1[1], q1[2], q1[3]);

    start = ret;
    drawR(L1, q1);
    end = ret;

    deltaX = 0;
    deltaY = div[1];
    if (div[0] == 0) {
      deltaY = q[3];
    }

    if (tmp[0] != tmp[1]) {
      width = tmp[0];
      height = tmp[1];
    } else {
      width = tmp[2];
      height = tmp[3];
    }

    if (tmp[0] == tmp[2]) {
      if (width >= height)
        P4(start, end, L1, q1, deltaX, deltaY);
      else
        P8(start, end, L1, q1, deltaX, deltaY);
    } else {
      if (width >= height)
        P1(start, end, L1, q1, deltaX, deltaY);
      else
        P5(start, end, L1, q1, deltaX, deltaY);
    }

    /* Draw L2. */
    tmp[0] = q2[0];
    tmp[1] = q2[1];
    tmp[2] = q2[2];
    tmp[3] = q2[3];
    normalizeDegeneratedL(tmp);

    Util.normalizePiece(q2);
    L2 = LIndex(q2[0], q2[1], q2[2], q2[3]);

    start = ret;
    drawR(L2, q2);
    end = ret;

    deltaX = 0;
    deltaY = 0;
    if (div[1] == 0) deltaX = div[0];

    if (tmp[0] != tmp[1]) {
      width = tmp[0];
      height = tmp[1];
    } else {
      width = tmp[2];
      height = tmp[3];
    }

    if (tmp[0] == tmp[2]) {
      if (width >= height)
        P4(start, end, L2, q2, deltaX, deltaY);
      else
        P8(start, end, L2, q2, deltaX, deltaY);
    } else {
      if (width >= height)
        P2(start, end, L2, q2, deltaX, deltaY);
      else
        P6(start, end, L2, q2, deltaX, deltaY);
    }
  }

  void drawR(int L, List<int> q) {
    int i;
    int start, end;
    int divisionType;

    if (Global.memory_type == MemType.TYPE4) {
      divisionType = (Global.solution[L] & Util.solucao) >> Util.descSol;
    } else {
      int h = Util.getKey(q[0], q[1], q[2], q[3], Global.memory_type);
      divisionType = (Global.solutionMap[L][h] & Util.solucao) >> Util.descSol;
    }

    const int HOMOGENEOUS = 0,
        B1 = 1,
        B2 = 2,
        B3 = 3,
        B4 = 4,
        B5 = 5,
        B6 = 6,
        B7 = 7,
        B8 = 8,
        B9 = 9;

    switch (divisionType) {
      case HOMOGENEOUS:

        /* Non-degenerated L. */
        if (q[0] != q[2]) {
          CutDirection cut = LCut(q);

          if (cut == CutDirection.VERTICAL) {
            // ret = drawBD(q[2], q[1], ret);
            start = ret;
            // ret = drawBD(normalize[q[0] - q[2]], q[3], ret);
            end = ret;
            for (i = start; i < end; i++) {
              shiftX(i, q[2]);
            }
          } else {
            start = ret;
            // ret = drawBD(q[2], normalize[q[1] - q[3]], ret);
            end = ret;
            for (i = start; i < end; i++) {
              shiftY(i, q[3]);
            }
            // ret = drawBD(q[0], q[3], ret);
          }
        }
        /* Degenerated L (rectangle). */
        else {
          // ret = drawBD(q[0], q[1], ret);
        }
        break;

      case B1:
        drawB1(L, q);
        break;
      case B2:
        // drawB2(L, q);
        break;
      case B3:
        // drawB3(L, q);
        break;
      case B4:
        // drawB4(L, q);
        break;
      case B5:
        // drawB5(L, q);
        break;
      case B6:
        // drawB6(L, q);
        break;
      case B7:
        // drawB7(L, q);
        break;
      case B8:
        // drawB8(L, q);
        break;
      case B9:
        // drawB9(L, q);
        break;
      default:
        break;
    }
  }
}
