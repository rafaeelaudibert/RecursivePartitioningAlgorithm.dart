verbatimtex
%&latex
\documentclass{article}
\begin{document}
etex
beginfig(-1);
u=0.200000cm;
path p;p := (0u,0u)--(0u,100u)--(100u,100u)--(100u,0u)--cycle;
fill p withcolor 0.2black + 0.7 white;
deltaX = 100u;
stepX = 11.5;
for x = -100u step stepX until 100u:
  draw (x, 0u)--(x + deltaX, 100u) withcolor 0.1 white;
endfor;
clip currentpicture to p;
draw p withcolor 0.2black + 0.7 white;
draw (0u,0u)--(0u,100u)--(100u,100u)--(100u,0u)--cycle;
fill (0u,0u)--(0u,19u)--(19u,19u)--(19u,0u)--cycle withcolor white;
draw (0u,0u)--(0u,19u)--(19u,19u)--(19u,0u)--cycle;
fill (0u,19u)--(0u,38u)--(19u,38u)--(19u,19u)--cycle withcolor white;
draw (0u,19u)--(0u,38u)--(19u,38u)--(19u,19u)--cycle;
fill (0u,38u)--(0u,57u)--(19u,57u)--(19u,38u)--cycle withcolor white;
draw (0u,38u)--(0u,57u)--(19u,57u)--(19u,38u)--cycle;
fill (0u,57u)--(0u,76u)--(19u,76u)--(19u,57u)--cycle withcolor white;
draw (0u,57u)--(0u,76u)--(19u,76u)--(19u,57u)--cycle;
fill (0u,76u)--(0u,95u)--(19u,95u)--(19u,76u)--cycle withcolor white;
draw (0u,76u)--(0u,95u)--(19u,95u)--(19u,76u)--cycle;
fill (19u,0u)--(19u,19u)--(38u,19u)--(38u,0u)--cycle withcolor white;
draw (19u,0u)--(19u,19u)--(38u,19u)--(38u,0u)--cycle;
fill (19u,19u)--(19u,38u)--(38u,38u)--(38u,19u)--cycle withcolor white;
draw (19u,19u)--(19u,38u)--(38u,38u)--(38u,19u)--cycle;
fill (19u,38u)--(19u,57u)--(38u,57u)--(38u,38u)--cycle withcolor white;
draw (19u,38u)--(19u,57u)--(38u,57u)--(38u,38u)--cycle;
fill (19u,57u)--(19u,76u)--(38u,76u)--(38u,57u)--cycle withcolor white;
draw (19u,57u)--(19u,76u)--(38u,76u)--(38u,57u)--cycle;
fill (19u,76u)--(19u,95u)--(38u,95u)--(38u,76u)--cycle withcolor white;
draw (19u,76u)--(19u,95u)--(38u,95u)--(38u,76u)--cycle;
fill (38u,0u)--(38u,19u)--(57u,19u)--(57u,0u)--cycle withcolor white;
draw (38u,0u)--(38u,19u)--(57u,19u)--(57u,0u)--cycle;
fill (38u,19u)--(38u,38u)--(57u,38u)--(57u,19u)--cycle withcolor white;
draw (38u,19u)--(38u,38u)--(57u,38u)--(57u,19u)--cycle;
fill (38u,38u)--(38u,57u)--(57u,57u)--(57u,38u)--cycle withcolor white;
draw (38u,38u)--(38u,57u)--(57u,57u)--(57u,38u)--cycle;
fill (38u,57u)--(38u,76u)--(57u,76u)--(57u,57u)--cycle withcolor white;
draw (38u,57u)--(38u,76u)--(57u,76u)--(57u,57u)--cycle;
fill (38u,76u)--(38u,95u)--(57u,95u)--(57u,76u)--cycle withcolor white;
draw (38u,76u)--(38u,95u)--(57u,95u)--(57u,76u)--cycle;
fill (57u,0u)--(57u,19u)--(76u,19u)--(76u,0u)--cycle withcolor white;
draw (57u,0u)--(57u,19u)--(76u,19u)--(76u,0u)--cycle;
fill (57u,19u)--(57u,38u)--(76u,38u)--(76u,19u)--cycle withcolor white;
draw (57u,19u)--(57u,38u)--(76u,38u)--(76u,19u)--cycle;
fill (57u,38u)--(57u,57u)--(76u,57u)--(76u,38u)--cycle withcolor white;
draw (57u,38u)--(57u,57u)--(76u,57u)--(76u,38u)--cycle;
fill (57u,57u)--(57u,76u)--(76u,76u)--(76u,57u)--cycle withcolor white;
draw (57u,57u)--(57u,76u)--(76u,76u)--(76u,57u)--cycle;
fill (57u,76u)--(57u,95u)--(76u,95u)--(76u,76u)--cycle withcolor white;
draw (57u,76u)--(57u,95u)--(76u,95u)--(76u,76u)--cycle;
fill (76u,0u)--(76u,19u)--(95u,19u)--(95u,0u)--cycle withcolor white;
draw (76u,0u)--(76u,19u)--(95u,19u)--(95u,0u)--cycle;
fill (76u,19u)--(76u,38u)--(95u,38u)--(95u,19u)--cycle withcolor white;
draw (76u,19u)--(76u,38u)--(95u,38u)--(95u,19u)--cycle;
fill (76u,38u)--(76u,57u)--(95u,57u)--(95u,38u)--cycle withcolor white;
draw (76u,38u)--(76u,57u)--(95u,57u)--(95u,38u)--cycle;
fill (76u,57u)--(76u,76u)--(95u,76u)--(95u,57u)--cycle withcolor white;
draw (76u,57u)--(76u,76u)--(95u,76u)--(95u,57u)--cycle;
fill (76u,76u)--(76u,95u)--(95u,95u)--(95u,76u)--cycle withcolor white;
draw (76u,76u)--(76u,95u)--(95u,95u)--(95u,76u)--cycle;
endfig;
end;
