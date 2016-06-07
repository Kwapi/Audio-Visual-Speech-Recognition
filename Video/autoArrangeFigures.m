function autoArrangeFigures(NH, NW)
% INPUT  :
%        NH : number of grid of height direction
%        NW : number of grid of width direction
% OUTPUT :
%
% get every figures that are opened now and arrange them.
%
% autoArrangeFigures selects automatically Monitor1.
% If you are dual(or more than that) monitor user, I recommend to set wide
% monitor as Monitor1.
%
% if you want arrange automatically, type 'autoArrangeFigures(0,0)' or 'autoArrangeFigures()'. 
%    But maximum number of figures for automatic mode is 27.
%
% if you want specify grid for figures, give numbers for parameters.
%    but if your grid size is smaller than required one for accommodating
%    all figures, this function changes to automatic mode and if more
%    figures are opend than maximum number, then it gives error.
% 
% leejaejun, Koreatech, Korea Republic, 2014.12.13
% jaejun0201@gmail.com

if nargin < 2
    NH = 0;
    NW = 0;
end

N_FIG = NH * NW;
if N_FIG == 0
    autoArrange = 1;
else
    autoArrange = 0;
end

figHandle = sort(findobj('Type','figure'));
n_fig = size(figHandle,1);
if n_fig <= 0
    warning('figures are not found');
    return
end

screen_sz = get(0,'ScreenSize');
scn_h = screen_sz(4);
scn_w = screen_sz(3);

if autoArrange==0
    if n_fig > N_FIG
        autoArrange = 1;
        warning('too many figures than you told. change to autoArrange');
    else
        nh = NH;
        nw = NW;
    end
end

if autoArrange == 1
    grid = [2 2 2 2 2 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4;
            3 3 3 3 3 3 3 3 4 4 4 5 5 5 5 5 5 5 5 6 6 6 7 7 7 7 7]';
   
    if n_fig > length(grid)
        warning('too many figures(maximum = %d)',length(grid))
        return
    end
    
    if scn_w > scn_h
        nh = grid(n_fig,1);
        nw = grid(n_fig,2);
    else
        nh = grid(n_fig,2);
        nw = grid(n_fig,1);
    end
end

fig_h = (scn_h-50)/nh;
fig_w = scn_w/nw;

fig_cnt = 1;
for i=1:1:nh
    for k=1:1:nw
        if fig_cnt>n_fig
            return
        end
        fig_pos = [1+fig_w*(k-1) scn_h-fig_h*i fig_w fig_h];
        set(figHandle(fig_cnt),'OuterPosition',fig_pos);
        fig_cnt = fig_cnt + 1;
    end
end

end