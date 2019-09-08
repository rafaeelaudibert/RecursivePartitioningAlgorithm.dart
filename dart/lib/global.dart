import "sets.dart";
import "draw.dart";

class CutPoint {
  int x1 = 0, x2 = 0, y1 = 0, y2 = 0, homogeneous = 0;

  CutPoint(this.x1, this.x2, this.y1, this.y2, this.homogeneous);

  CutPoint.zeroed(this.homogeneous);
}

class Global {
  /* Lower and upper bounds of each rectangular subproblem. */
  static List<List<int>> lowerBound, upperBound;

  /* Arrays of indices for indexing the matrices that store information
   * about rectangular subproblems (L,W), where (L,W) belongs to X' x Y'
   * and X' and Y' are the raster points sets associated to (L,l,w) and
   * (W,l,w), respectively. */
  static List<int> indexX, indexY;

  /* Set of integer conic combinations of l and w:
   * X = {x | x = rl + sw, with r,w in Z and r,w >= 0} */
  static Set normalSetX;

  /* Array that stores the normalized values of each integer between 0 and
   * L (dimension of the problem):
   * normalize[x] = max {r in X' | r <= x} */
  static List<int> normalize;

  /* Store the solutions of the subproblems. */
  static List<Map> solutionMap;
  static List<int> solution;

  /* Store the division points in the rectangular and in the L-shaped
   * pieces associated to the solutions found. */
  static List<Map> divisionPointMap;
  static List<int> divisionPoint;

  /* Dimensions of the boxes to be packed. */
  static int l, w;

  /* Type of the structure used to store the solutions. */
  static MemType memory_type;

  /* Store the points that determine the divisions of the rectangles. */
  static List<List<CutPoint>> cutPoints;

  /* Raster points */
  static List<int> indexRasterX, indexRasterY;
  static int numRasterX, numRasterY;
}
