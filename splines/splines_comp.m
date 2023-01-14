knot_vector = [0,0,0,0,1,2,4,6,8,9,11,12,13,13,13,16,18,21,24,26,28,30,32,35,43,43,43,43];
coeff_vector = [0.2,0.3,0.4,0.42,0.36,0.42,0.5,0.56,0.53,0.59,0.57,0.54,0.58,0.42,0.48,0.36,0.22,0.28,0.24,0.30,0.25,0.29,0.25,0.33];

splines_comb(100, knot_vector, coeff_vector);

function splines_comb(precision,knot_vector,coeff_vector)

% subroutine calculating number of basis functions
compute_nr_basis_functions = @(knot_vector,p) size(knot_vector, 2) - p - 1;
% subroutine generating mesh for drawing basis functions
mesh = @(a,c) [a:(c-a)/precision:c];
% subroutine drawing basis functions
plot_spline = @(knot_vector,p,nr,x) plot(x,compute_splines(knot_vector,p,nr,x));

% computing order of polynomials
p = compute_p(knot_vector);
% validation of knot vector construction
t = check_sanity(knot_vector,p);
% if knot vector is poorly constructed - stop further processing
if (~t)
  disp("Poorly constructed knot_vector")
  return
end
% computating number of basis functions
nr = compute_nr_basis_functions(knot_vector,p);

% beginning of drawing range
x_begin = knot_vector(1);
% end of drawing range
x_end = knot_vector(size(knot_vector,2));
x=mesh(x_begin,x_end);

% drawing first basis function
plot_spline(knot_vector,p,1,x);

% keep old window with plots in order to draw next functions
hold on
% drawing rest of basis functions
for i=2:nr
  plot_spline(knot_vector,p,i,x);
end

% if coefficients vector is poorly constructed - stop further processing
if (nr ~= length(coeff_vector))
  disp("Poorly constructed coeff_vector")
  fprintf('Coefficient vector should contain %d elements\n', nr);
  return
end

u = 0;

for i=1:nr
  u = u + coeff_vector(i) * compute_splines(knot_vector,p,i,x);
end

plot(x,u);

% next draw will erase old plots
hold off




% Subroutine computing order of polynomials
function p=compute_p(knot_vector)

% first entry in knot_vector
  initial = knot_vector(1);
% lenght of knot_vector
  kvsize = size(knot_vector,2);
  p = 0;

% checking number of repetitions of first entry in knot_vector
  while (p+2 <= kvsize) && (initial == knot_vector(p+2))
    p = p+1;
  end
  
  return
end

% Subroutine computing basis functions according to recursive Cox-de-Boor formulae
function y=compute_splines(knot_vector,p,nr,x)

y=compute_spline(knot_vector,p,nr,x);
%y=y.*sin(pi/10*x);
return
end

% Subroutine computing basis functions according to recursive Cox-de-Boor formulae
function y=compute_spline(knot_vector,p,nr,x)
  
% function (x-x_i)/(x_{i-p}-x_i)
  fC= @(x,a,b) (x-a)/(b-a);
% function (x_{i+p+1}-x)/(x_{i+p+1}-x_{i+1})
  fD= @(x,c,d) (d-x)/(d-c);
  
% x_i  
  a = knot_vector(nr);
% x_{i-p} 
  b = knot_vector(nr+p);
% x_{i+1}
  c = knot_vector(nr+1);
% x_{i+p+1}
  d = knot_vector(nr+p+1);

% linear function for p=0
  if (p==0)
    y = 0 .* (x < a) + 1 .* (a <= x & x <= d) + 0 .* (x > d);
    return
  end

% B_{i,p-1}  
  lp = compute_spline(knot_vector,p-1,nr,x);
% B_{i+1,p-1}
  rp = compute_spline(knot_vector,p-1,nr+1,x);
  
% (x-x_i)/(x_{i-p)-x_i)*B_{i,p-1}  
  if (a==b)
% if knots in knot_vector are repeated we have to include it in formula
    y1 = 0 .* (x < a) + 1 .* (a <= x & x <= b) + 0 .* (x > b);
  else
    y1 = 0 .* (x < a) + fC(x,a,b) .* (a <= x & x <= b) + 0 .* (x > b);
  end
  
% (x_{i+p+1}-x)/(x_{i+p+1)-x_{i+1})*B_{i+1,p-1}
  if (c==d)
% if knots in knot_vector are repeated we have to include it in formula
    y2 = 0 .* (x < c) + 1 .* (c < x & x <= d) + 0 .* (d < x);
  else
    y2 = 0 .* (x < c) + fD(x,c,d) .* (c < x & x <= d) + 0 .* (d < x);
  end
  
  y = lp .* y1 + rp .* y2;
  return
end


% Subroutine checking sanity of knot_vector
function t=check_sanity(knot_vector,p)

  initial = knot_vector(1);
  kvsize = size(knot_vector,2);

  t = true;
  counter = 1;

% if number of repeated knots at the beginning of knot_vector doesn't match polynomial order
  for i=1:p+1
    if (initial ~= knot_vector(i))
% return FALSE
      t = false;
      return
    end
  end

% if there are too many repeated knots in the middle of knot_vector
  for i=p+2:kvsize-p-1
    if (initial == knot_vector(i))
      counter = counter + 1;
      if (counter > p)
% return FALSE
        t = false;
        return
      end
    else
      initial = knot_vector(i);
      counter = 1;
    end
  end

  initial = knot_vector(kvsize);
  
% if number of repeated knots at the end of knot_vector doesn't match polynomial order
  for i=kvsize-p:kvsize
    if (initial ~= knot_vector(i))
% return FALSE
      t = false;
      return
    end
  end
  
% if subsequent element in knot_vector is smaller than previous one
  for i=1:kvsize-1
    if (knot_vector(i)>knot_vector(i+1))
% return FALSE
      t = false;
      return
    end
  end

  return

end



end