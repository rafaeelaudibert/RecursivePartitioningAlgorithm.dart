import 'package:tuple/tuple.dart';
import "global.dart";
import "dart:io";

class Set {
  List<int> points = new List<int>();

  /**
  * Create a new set
  *
  * Return:
  * set - The set created.
  */
  Set() {}

  /**
   * Returns the size of the set
   * 
   * Return:
   * size - The size of the points in the set
   */
  int get size => this.points.length;

  /**
  * Insert an element into the specified set, in the case it does not
  * belong to the set yet.
  *
  * Parameters:
  * element - The element to be inserted.
  *
  * Return:
  * The size of the set after this insertion.
  */
  int insert(int element) {
    if (this.points.length == 0 || this.points.last < element)
      this.points.add(element);

    return this.points.length;
  }

/**
 * Construct the raster points sets X' and Y', which are defined as
 *
 * X' = {<L - x>_X | x \in X} U {0}
 * Y' = {<W - y>_Y | y \in Y} U {0}
 *
 * where X and Y are the integer conic combinations sets for L and W,
 * respectively, and <s'>_S = max {s | s \in S, s <= s'}.
 *
 * Parameters:
 * L                 - Length of the rectangle.
 * W                 - Width of the rectangle.
 * rasterPointsX     - Pointer to the raster points set X'.
 * rasterPointsY     - Pointer to the raster points set Y'.
 * conicCombinations - Set of integer conic combinations of l and w.
 *
 * Remark: it suposes that the integer conic combinations set is
 * sorted.
 */
  Tuple2<Set, Set> constructRasterPoints(int L, int W) {
    // Maximum raster points X size
    int xSize = this.size;
    for (int i = xSize - 1; i >= 0 && this.points[i] > L; i--) xSize--;

    // Maximum raster points X size
    int ySize = this.size;
    for (int i = ySize - 1; i >= 0 && this.points[i] > W; i--) ySize--;

    // Construct the raster points for L.
    Set rasterPointsX = Set();
    for (int i = xSize - 1; i >= 0; i--)
      rasterPointsX.insert(Global.normalize[L - this.points[i]]);

    // Construct the raster points for W.
    Set rasterPointsY = Set();
    for (int i = ySize - 1; i >= 0; i--)
      rasterPointsY.insert(Global.normalize[W - this.points[i]]);

    return Tuple2<Set, Set>(rasterPointsX, rasterPointsY);
  }

  /**
   * Construct the set X (this) of integer conic combinations of l and w.
   *
   * X = {x | x = rl + sw, x <= L, r,s >= 0 integers}
   *
   * Parameters:
   * L - Length of the rectangle.
   * l - Length of the boxes to be packed.
   * w - Width of the boxes to be packed.
   */
  void constructConicCombinations(int L, int l, int w) {
    List<int> inX = new List<int>.filled(L + 2, 0);
    List<int> c = new List<int>.filled(L + 2, 0);

    this.points.add(0);
    inX[0] = 1;

    for (int i = 0; i <= L; i++) c[i] = 0;

    for (int i = l; i <= L; i++) {
      if (c[i] < c[i - l] + l) {
        c[i] = c[i - l] + l;
      }
    }

    for (int i = w; i <= L; i++) {
      if (c[i] < c[i - w] + w) {
        c[i] = c[i - w] + w;
      }
    }

    for (int i = 1; i <= L; i++) {
      if (c[i] == i && inX[i] == 0) {
        this.points.add(i);
        inX[i] = 1;
      }
    }

    // Insert L in this set
    if (this.points.last != L) this.points.add(L);
  }
}
