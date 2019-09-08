import 'draw.dart';
import 'global.dart';

class Util {
  static const int ptoDiv1 = 2047;
  static const int ptoDiv2 = 4192256;
  static const int ptoDiv3 = 4290772992;

  static const int nRet = 134217727;
  static const int solucao = 2013265920;
  static const int descSol = 27;

  static const int descPtoDiv2 = 11;
  static const int descPtoDiv3 = 22;

  /**
 * Return the index associated to the L-shaped piece (q0, q1, q2, q3).
 */
  static int LIndex(int q0, int q1, int q2, int q3, MemType type) {
    switch (type) {
      case MemType.TYPE4:
        return (((Global.indexRasterX[q0] * Global.numRasterY) +
                            Global.indexRasterY[q1]) *
                        Global.numRasterX +
                    Global.indexRasterX[q2]) *
                Global.numRasterY +
            Global.indexRasterY[q3];

      case MemType.TYPE3:
        return (((Global.indexRasterX[q0] * Global.numRasterY) +
                    Global.indexRasterY[q1]) *
                Global.numRasterX +
            Global.indexRasterX[q2]);

      case MemType.TYPE2:
        return ((Global.indexRasterX[q0] * Global.numRasterY) +
            Global.indexRasterY[q1]);

      case MemType.TYPE1:
        return Global.indexRasterX[q0];

      default:
        return 0;
    }
  }

  /**
   * Return the index associated to the L-shaped piece (q0, q1, q2, q3).
   */
  static int getKey(int q0, int q1, int q2, int q3, MemType type) {
    switch (type) {
      case MemType.TYPE4:
        return 0;

      case MemType.TYPE3:
        return q3;

      case MemType.TYPE2:
        return ((Global.indexRasterX[q2] * Global.numRasterY) +
            Global.indexRasterY[q3]);

      case MemType.TYPE1:
        return ((Global.indexRasterY[q1]) * Global.numRasterX +
                    Global.indexRasterX[q2]) *
                Global.numRasterY +
            Global.indexRasterY[q3];

      default:
        return 0;
    }
  }

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B1, and put them in the standard position.
   *
   *                  (X,Y)
   * +------------+     o
   * |            |
   * |            |(x,y)                     (x,Y-y')                     (X,y)
   * |      +-----o-----+         +------+     o         +-----------+      o
   * |  L1  |           |         |      |               |           |
   * |      |     L2    |   -->   |      |(x',Y-y)       |           |(X-x',y')
   * +------o           |         |  L1  o-----+         |     L2    o------+
   * |   (x',y')        |         |            |         |                  |
   * |                  |         |            |         |                  |
   * +------------------+         +------------+         +------------------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB1(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = q[2];
    q1[1] = Global.normalize[q[1] - i[1]];
    q1[2] = i[0];
    q1[3] = Global.normalize[q[1] - q[3]];

    /* L2 */
    q2[0] = q[0];
    q2[1] = q[3];
    q2[2] = Global.normalize[q[0] - i[0]];
    q2[3] = i[1];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B2, and put them in the standard position.
   *
   *                  (X,Y)
   * +------------+     o
   * |            |
   * |   (x',y')  |                          (x,Y-y)                     (X,y')
   * +------o     |               +-----+      o        +------+           o
   * |      | L1  |               |     |               |      |
   * |      |     |(x,y)    -->   |     |(x-x',Y-y')    |      |(x',y)
   * |      +-----o-----+         |     o------+        |      o-----------+
   * |  L2              |         |  L1        |        |  L2              |
   * |                  |         |            |        |                  |
   * +------------------+         +------------+        +------------------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB2(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = q[2];
    q1[1] = Global.normalize[q[1] - q[3]];
    q1[2] = Global.normalize[q[2] - i[0]];
    q1[3] = Global.normalize[q[1] - i[1]];

    /* L2 */
    q2[0] = q[0];
    q2[1] = i[1];
    q2[2] = i[0];
    q2[3] = q[3];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B3, and put them in the standard position.
   *
   *                  (X,Y)                         (X,Y)
   * +------+-----+     o         +------+           o
   * |      |     |               |      |
   * |      |     |(x,y)          |      |                         (X-x',Y-y')
   * |      | L2  o-----+         |      |                  +-----+     o
   * |      |           |         |      |                  |     |
   * |  L1  |           |   -->   |  L1  |(x',y')           |     |(x-x',y-y')
   * |      o-----------+         |      o-----------+      | L2  o-----+ 
   * |   (x',y')        |         |                  |      |           |
   * |                  |         |                  |      |           |
   * +------------------+         +------------------+      +-----------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB3(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = q[0];
    q1[1] = q[1];
    q1[2] = i[0];
    q1[3] = i[1];

    /* L2 */
    q2[0] = Global.normalize[q[0] - i[0]];
    q2[1] = Global.normalize[q[1] - i[1]];
    q2[2] = Global.normalize[q[2] - i[0]];
    q2[3] = Global.normalize[q[3] - i[1]];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B4, and put them in the standard position.
   *
   *                  (X,Y)                 (x',Y)
   * +------+           o         +------+     o
   * |      |                     |      |
   * |      |(x,y)                |      |                     (X-x,y)
   * |      o-----------+         |      |             +-----+     o
   * |  L1  |           |         |  L1  |             |     |
   * |      |  (x',y')  |   -->   |      |(x,y')       |     |(X-x',y-y')
   * |      +-----o     |         |      o-----+       |     o-----+
   * |            | L2  |         |            |       |  L2       |
   * |            |     |         |            |       |           |
   * +------------+-----+         +------------+       +-----------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB4(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = i[0];
    q1[1] = q[1];
    q1[2] = q[2];
    q1[3] = i[1];

    /* L2 */
    q2[0] = Global.normalize[q[0] - q[2]];
    q2[1] = q[3];
    q2[2] = Global.normalize[q[0] - i[0]];
    q2[3] = Global.normalize[q[3] - i[1]];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B5, and put them in the standard position.
   *
   *                  (X,Y)                  (x,Y)
   * +------------+     o         +------+     o
   * |            |               |      |
   * |     L1     |(x,y)          |      |                    (X-x',y)
   * |            o-----+         |      |(x',Y-y')    +-----+     o
   * |   (x',y')  |     |         |      o-----+       |     |
   * |      o-----+     |   -->   |            |       |     o-----+
   * |      |           |         |     L1     |       | (X-x,y')  |
   * |      |     L2    |         |            |       |           |
   * |      |           |         |            |       |    L2     |
   * +------+-----------+         +------------+       +-----------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB5(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = q[2];
    q1[1] = q[1];
    q1[2] = i[0];
    q1[3] = Global.normalize[q[1] - i[1]];

    /* L2 */
    q2[0] = Global.normalize[q[0] - i[0]];
    q2[1] = q[3];
    q2[2] = Global.normalize[q[0] - q[2]];
    q2[3] = i[1];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the rectangle in two L-shaped pieces, according to the
   * subdivision B6, and put them in the standard position.
   *
   *                      (X,Y)                 (x'',Y)              (X-x',Y)
   * +-------------+--------o         +------+      o     +--------+      o
   * |             |        |         |      |            |        |
   * |   (x',y')   |   L2   |         |      |            |        |(X-x'',y')
   * |      o------o        |   -->   |      |(x',Y-y')   |        o------+
   * |      |  (x'',y')     |         |  L1  o------+     |   L2          |
   * |  L1  |               |         |             |     |               |
   * |      |               |         |             |     |               |
   * +------+---------------+         +-------------+     +---------------+
   *
   * Parameters:
   * i  - Array of three elements such that i[0] = x', i[1] = y' and i[2] = x''.
   *
   * q  - The rectangle to be divided. q = {X, Y, X, Y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB6(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = i[2];
    q1[1] = q[1];
    q1[2] = i[0];
    q1[3] = Global.normalize[q[1] - i[1]];

    /* L2 */
    q2[0] = Global.normalize[q[0] - i[0]];
    q2[1] = q[1];
    q2[2] = Global.normalize[q[0] - i[2]];
    q2[3] = i[1];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the rectangle in two L-shaped pieces, according to the
   * subdivision B7, and put them in the standard position.
   *
   *             (X,Y)
   * +-------------o
   * |             |
   * |   (x',y'')  |                                           (X,y'')
   * |      o------+                     (X,Y-y')    +------+      o
   * |      |      |         +------+      o         |      |
   * |  L1  |  L2  |         |      |                |      |
   * |      |      |   -->   |      |                |      |(X-x',y')
   * +------o      |         |      |(x',Y-y'')      |      o------+
   * |   (x',y')   |         |  L1  o------+         |             |
   * |             |         |             |         |      L2     |
   * |             |         |             |         |             |
   * +-------------+         +-------------+         +-------------+
   *
   * Parameters:
   * i  - Array of three elements such that i[0] = x', i[1] = y' and i[2] = y''.
   *
   * q  - The rectangle to be divided. q = {X, Y, X, Y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB7(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = q[0];
    q1[1] = Global.normalize[q[1] - i[1]];
    q1[2] = i[0];
    q1[3] = Global.normalize[q[1] - i[2]];

    /* L2 */
    q2[0] = q[0];
    q2[1] = i[2];
    q2[2] = Global.normalize[q[0] - i[0]];
    q2[3] = i[1];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B8, and put them in the standard position.
   *
   *                  (X,Y)                  (x,Y)
   * +------------+     o         +------+     o
   * |            |               |      |
   * |   (x',y')  |               |      |                     (X-x',y')
   * |      o-----+               |      |              +-----+     o
   * |      |     |               |  L1  |              |     |
   * |  L1  |     |(x,y)    -->   |      |(x',Y-y')     |     |(x-x',y)
   * |      |     o-----+         |      o-----+        |     o-----+
   * |      |  L2       |         |            |        |  L2       |
   * |      |           |         |            |        |           |
   * +------+-----------+         +------------+        +-----------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB8(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = q[2];
    q1[1] = q[1];
    q1[2] = i[0];
    q1[3] = Global.normalize[q[1] - i[1]];

    /* L2 */
    q2[0] = Global.normalize[q[0] - i[0]];
    q2[1] = i[1];
    q2[2] = Global.normalize[q[2] - i[0]];
    q2[3] = q[3];
  }

  /******************************************************************
   ******************************************************************/

  /**
   * Divide the L-shaped piece in two new L-shaped pieces, according to
   * the subdivision B9, and put them in the standard position.
   *
   *                  (X,Y)
   * +---------+        o
   * |         |
   * |         |(x,y)                                                      (X,y)
   * |   L1    o---+----+                    (x',Y-y')    +----+             o
   * |             |    |         +---------+   o         |    |
   * |             |    |         |         |             |    |(X-x',y')
   * +-------------o    |   -->   |         |(x,y-y')     |    o-------------+
   * |          (x',y') |         |   L1    o---+         |                  |
   * |     L2           |         |             |         |        L2        |
   * |                  |         |             |         |                  |
   * +------------------+         +-------------+         +------------------+
   *
   * Parameters:
   * i  - Array of two elements such that i[0] = x' and i[1] = y'.
   *
   * q  - The L-shaped piece to be divided. q = {X, Y, x, y}.
   *
   * q1 - Array to store L1.
   *
   * q2 - Array to store L2.
   */
  static void standardPositionB9(
      List<int> i, List<int> q, List<int> q1, List<int> q2) {
    /* L1 */
    q1[0] = i[0];
    q1[1] = Global.normalize[q[1] - i[1]];
    q1[2] = q[2];
    q1[3] = Global.normalize[q[3] - i[1]];

    /* L2 */
    q2[0] = q[0];
    q2[1] = q[3];
    q2[2] = Global.normalize[q[0] - i[0]];
    q2[3] = i[1];
  }

  /*
  * Normalize the L-piece (q0,q1,q2,q3) considering the symmetries
  * below, defined in [3].
  *
  * [3] R. Morabito and S. Morales. A simple and effective recursive
  *     procedure for the manufacturer's pallet loading
  *     problem. Journal of the Operational Research Society, volume
  *     49, number 8, pages 819-828, 1998.
  *
  * Symmetry considerations for (i,j,i',j'):
  *
  * (1) i >= i' and j >= j', from the definition of standardly positioned
  * L's;
  *
  * (2) i >= j, otherwise we could use (j, i, j', i');
  *
  * (3) i = j implies i' >= j', otherwise we again could use (j,i,j',i');
  *
  * (4) i = i' if and only if j = j'. This equivalence follows to avoid
  * degenerated L's which are not explicit rectangles: in terms of
  * occupancy, (i,j,i,j') with j' < j can be replaced by (i,j,i,j) and
  * (i,j,i',j) with i' < i can also be replaced by (i,j,i,j).
  *
  * The normalization (i,j,i',j')^N of a quadruple (i,j,i',j') is defined
  * as:
  *
  * - if (i,j,i',j') satisfies (1)-(4), then (i,j,i',j')^N = (i,j,i',j');
  *
  * - if 0 = i' < i and 0 < j' < j, then (i,j,i',j')^N = (i,j',i,j');
  *
  * - if 0 < i' < i and 0 = j' < j, then (i,j,i',j')^N = (i',j,i',j);
  *
  * - if 0 < i' = i and 0 < j' < j, then (i,j,i',j')^N = (i,j,i,j);
  *
  * - if 0 < i' < i and 0 < j' = j, then (i,j,i',j')^N = (i,j,i,j);
  *
  * - if 0 < i' < i, 0 < j' < j and i < j, then (i,j,i',j')^N = (j,i,j',i');
  *
  * - if 0 < i' < i, 0 < j' < j, i = j and i' < j', then (i,j,i',j')^N =
  *   (j,i,j',i');
  *
  *
  * Parameters:
  * q - The L-piece to be normalized.
  */
  static void normalizePiece(List<int> q) {
    int i, j, i1, j1;

    i = q[0];
    j = q[1];
    i1 = q[2];
    j1 = q[3];

    /* Rule (4) for degenerated L's. */
    if (i1 == 0) {
      i1 = i;
      j = j1;
    } else if (j1 == 0) {
      j1 = j;
      i = i1;
    } else if (i1 == i || j1 == j) {
      i1 = i;
      j1 = j;
    }

    /* If the area of this L-piece is less than the area of the box,
    * this L-piece is discarded. */
    if (i * j - (i - i1) * (j - j1) < Global.l * Global.w) {
      q[0] = -1;
      return;
    }

    if (i == i1 && j == j1 && i < j) {
      int tmp = i;
      i = j;
      j = tmp;

      tmp = i1;
      i1 = j1;
      j1 = tmp;
    }

    if (0 < i1 && i1 < i && 0 < j1 && j1 < j && i < j) {
      int tmp = i;
      i = j;
      j = tmp;

      tmp = i1;
      i1 = j1;
      j1 = tmp;
    } else if (0 < i1 && i1 < i && 0 < j1 && j1 < j && i == j && i1 < j1) {
      int tmp = i1;
      i1 = j1;
      j1 = tmp;
    }

    q[0] = i;
    q[1] = j;
    q[2] = i1;
    q[3] = j1;
  }
}
