
if known context_gplot : endinput; fi;

boolean context_gplot ; context_gplot := true;

	string gnuplotversion;

	def gp_setup_before =
	enddef;

	def gp_setup_after =
	enddef;

	newinternal gp_align_center, gp_align_left, gp_align_right;
	gp_align_center := 0;
	gp_align_left   := 1;
	gp_align_right  := 2;


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%
	%% Colors & Dashes
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	boolean gp_use_color;  gp_use_color  := true;
	boolean gp_use_dashed; gp_use_dashed := true;

	% default background color (should we set it somewhere?)
	color gp_color_background; gp_color_background := white;
	% default foreground color (also set in t-gnuplot.tex)
	color gp_color_foreground; gp_color_foreground := black;
	% current color
	color gp_color_current;    gp_color_current := gp_color_foreground;

	% colors corresponding to linetypes
	%
	% LT_AXIS       (-1)
	% LT_BLACK      (-2)
	% LT_NODRAW     (-3)
	% LT_BACKGROUND (-4)
	% LT_UNDEFINED  (-5)

	color gp_color_lt[];
	numeric gp_num_linetype; gp_num_linetype := 9;
	gp_color_lt[-4] = gp_color_background;
	gp_color_lt[-3] = gp_color_background; % TODO: nodraw!!!
	gp_color_lt[-2] = gp_color_foreground;
	gp_color_lt[-1] = gp_color_foreground;
	gp_color_lt[0] = red;
	gp_color_lt[1] = green;
	gp_color_lt[2] = blue;
	gp_color_lt[3] = magenta;
	gp_color_lt[4] = cyan;
	gp_color_lt[5] = yellow;
	gp_color_lt[6] = black;
	gp_color_lt[7] = (1,.3,0); % orange; perhaps it's defined already
	gp_color_lt[8] = .5white;

	% dashes corresponding to linetypes - copied from PostScript terminal
	% perhaps check the other terminals as well!!!

	% scaling factor for dash lengths
	gp_scale_dashlength := 1;
	% TODO: set some sensible default scaling factor (compare with PostScript)
	gp_dashlength := 1;

	% TODO: watch out linecaps and linejoins !!! (possibly rewrite)
	% TODO: compare with PostScript lines and possibly fix,
	% so that they will match
	%
	% TODO: write a macro to make these definitions slightly nicer
	%
	% linecap := butt; ???
	picture gp_dash_lt[];
	gp_dash_lt[-3] := dashpattern(off 1) scaled (gp_scale_dashlength*gp_dashlength); % TODO: test!!!
	gp_dash_lt[-2] := dashpattern(on 1) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[-1] := dashpattern(on 1) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[0]  := dashpattern(on 1) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[1]  := dashpattern(on 4 off 2) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[2]  := dashpattern(on 2 off 3) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[3]  := dashpattern(on 1 off 1.5) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[4]  := dashpattern(on 6 off 2 on 1 off 2) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[5]  := dashpattern(on 3 off 3 on 1 off 3) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[6]  := dashpattern(on 2 off 2 on 2 off 6) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[7]  := dashpattern(on 1 off 2 on 6 off 2 on 1 off 2) scaled (gp_scale_dashlength*gp_dashlength);
	gp_dash_lt[8]  := dashpattern(on 2 off 2 on 2 off 2 on 2 off 2 on 2 off 4) scaled (gp_scale_dashlength*gp_dashlength);

	% returns the color for the given linetype modulo gp_num_linetype
	vardef gp_color_linetype(expr linetype) =
		(if linetype < -3:
			gp_color_lt[-3]
%		else:
		elseif linetype >= gp_num_linetype:
			gp_color_lt[(linetype mod gp_num_linetype)]
%			gp_color_lt[1]
		else:
			gp_color_lt[linetype]
		fi)
		% TODO: chech if the number is defined
		% TODO: check if gp_use_color
%		if linetype = -2 :
%			gp_color_lt[-2]
%		elseif linetype = -1 :
%			gp_color_lt[-1]
%		elseif linetype = -1 :
%			gp_color_lt[-3]
%		else :
%			% TODO: check if the number is defined
%			% check, if the number is positive
%			gp_color_lt[ (linetype mod gp_num_linetype) ]
%		fi;
	enddef;

	def gp_dash_linetype(expr linetype) =
		(if linetype < -3:
			gp_dash_lt[-3]
		elseif linetype >= gp_num_linetype:
			gp_dash_lt[(linetype mod gp_num_linetype)]
		else:
			gp_dash_lt[linetype]
		fi)
		% TODO: chech if the number is defined
		% TODO: check if gp_use_color
%		if linetype = -2 :
%			gp_color_lt[-2]
%		elseif linetype = -1 :
%			gp_color_lt[-1]
%		elseif linetype = -1 :
%			gp_color_lt[-3]
%		else :
%			% TODO: check if the number is defined
%			% check, if the number is positive
%			gp_color_lt[ (linetype mod gp_num_linetype) ]
%		fi;
	enddef;

	% sets the color so that it matches the color of linetype
	def gp_set_color_lt(expr linetype) =
		gp_color_current := gp_color_linetype(linetype);
	enddef;

	% sets the color so that it matches the color of linetype
	def gp_set_color_rgb(expr col) =
		gp_color_current := col;
	enddef;

	% sets the color either to gray or according to the palette
	def gp_set_color_frac(expr frac) =
		% TODO
		% "if palette = gray"
		gp_color_current := frac*white; % XXX: should this be (1-frac)*white perhaps?
		% else
	enddef;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%
	%% Palette
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% for "colorMode==SMPAL_COLOR_MODE_GRADIENT"
	% These variables are used to define interpolated color palettes:
   % there are gradient_num pairs of (frac/gray, color) mappings
%	numeric gp_palette.gradient_num;
%	numeric gp_palette.gradient[].frac;
%	color   gp_palette.gradient[].abc;
	%
	% see palette_color_mode in color.h
	newinternal
		gp_palette_color_mode_none,
		gp_palette_color_mode_gray,
		gp_palette_color_mode_rgb,
		gp_palette_color_mode_functions,
		gp_palette_color_mode_gradient;

	gp_palette_color_mode_none      := 0;
	gp_palette_color_mode_gray      := 1; % grayscale only
	gp_palette_color_mode_rgb       := 2; % one of several fixed transformations
	gp_palette_color_mode_functions := 3; % user-defined transforms
	gp_palette_color_mode_gradient  := 4; % interpolated table: explicitely defined or read from file

	% mapping formulae for gp_palette_color_mode_rgb
	numeric gp_palette_formula_r;
	numeric gp_palette_formula_g;
	numeric gp_palette_formula_b;

	% gamma for gray scale palettes only
	numeric gp_palette_gamma;

%	% color model: RGB/HSV/CMY; YIQ, XYZ and others not supported
%	newinternal gp_palette.model.rgb, gp_palette.model.hsv, gp_palette.model.cmy;%, gp_palette.model.yiq, gp_palette.model.xyz;
%	gp_palette.rgb := 0;
%	gp_palette.hsv := 1;
%	gp_palette.cmy := 2;
	%gp_palette.yiq := 3;
	%gp_palette.xyz := 4;
	
	% color model - RGB/HSV/CMY (ie. one of the models above)
%	numeric gp_palette.model;
	
	% for "colorMode == SMPAL_COLOR_MODE_FUNCTIONS"
	% R, G abd B for RGB
	% H, S and V for HSV
	% C, M and Y for CMY
%	color gp_palette.abc;
	
	% gamma (only used for gray scale palettes)
%	numeric gp_palette.gamma; gp_palette.gamma = 1;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%
	%% Scaling factors
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% scaling factor for points
	gp_scale_pointsize := 1;
	% scaling factor for line widths (for the whole plot)
	gp_scale_linewidth := 1;
	% current linewidth
	gp_linewidth := 1;
	% base linewidth: 0.4bp
	gp_internal_linewidth := 0.4;

	numeric gp_linetype; gp_linetype := -3;

	% set the scaling factor for point sizes
	def gp_set_pointsize(expr pointsize) =
		gp_scale_pointsize := pointsize;
	enddef;
	% set the scaling factor for line widths
	def gp_set_linewidth(expr linewidth) =
		gp_linewidth := linewidth*gp_scale_linewidth*gp_internal_linewidth;
	enddef;
	% set the linetype:
	% -3: solid with XOR, probably don't need that
	% -2: border, perhaps always with linejoin mitered
	% -1: axis
	%  0 or more : the rest
	def gp_set_linetype(expr linetype) =
		gp_linetype := linetype;
		gp_color_current := gp_color_linetype(linetype);
	enddef;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%
	%% FONTS & strings
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% scalig factor for text labels (relative to the document font)
	% if you set the font to 10pt and use scaligg factor 0.7,
	% you'll get 7pt, not 10pt
	numeric gp_scale_text; gp_scale_text := 1;

	% metapost offers the following operators:
	% - numeric defaultscale (1.0 stands for 10 or 12pt?) and can be changed
	% - string  defaultfont
	% - fontsize <defaultfont> (possible to write defaultfont or some other string)
	% however, these are probably too much system-dependent;
	% we use \switchtobodyfont[...] instead
	
	% this will be used for \switchtobodyfont[...] if non-empty
	% it may be anything valid that goes to \switchtobodyfont[...],
	% but from gnuplot it comes in the form
	%     "fontname,fontsize[,optional rm|ss|tt|...]"
	% examples:
	%     "antykwa,17pt" % Antykwa Torunska, 17pt
	%     "modern,,ss"   % [latin] modern sans
	%     ",10dd"        % default font (probably latin modern), 10 didot points
	% the purpose of that is that we want to know the size of fonts in order
	% to be able to adjust default char heights and widths
	%
	% It's possible to set the default font size in the preamble,
	% but then gnuplot doesn't know anything about the heights and widths
	% of characters
	string gp_font_current; gp_font_current = "";
	
	def gp_set_font(expr font) =
		% we could do some testing for errors, but well ... no real motivation
		gp_font_current := font;
	enddef;
	
	% returns an empty string if font should be the default one and
	% "\switchtobodyfont[currentfont,currentsize,possiblyothesettings:ss|tt|...]"
	% otherwise
	%
	% to be appended in front of any labels
	vardef gp_font_switch =
		if gp_font_current = "" :
			""
		else :
			"\switchtobodyfont["& gp_font_current & "]"
		fi
	enddef;
	
	% returns the aligned text according to the parameter align
	% (left, right or middle), but really, not switched as in ConTeX "
	% vertical alignment should be centered
	%
	% str may be a string or a picture
	% if it's a string, produce a picture with textext(str) first
	%
	vardef gp_the_text(expr align, str) =
		save pict, pict_strut; picture pict, pict_strut;

		% using "textext"
		if string str :
			% vertical alignment (center of strut in current font size)
			pict_strut := textext(gp_font_switch & "\strut");
			pict := textext(gp_font_switch & str) shifted - center pict_strut;
		% using \sometxt{}
		% TODO: alignment
		elseif picture str :
			pict := str shifted -center(str);
		% XXX: should be error report
		else :
			pict := nullpicture;
		fi;
		
		% horizontal alignment
		if align = gp_align_center :
			pict := pict shifted (xpart(.5[llcorner pict,lrcorner pict]),0);
		elseif align = gp_align_left :
			pict := pict shifted (- xpart(llcorner pict),0);
		elseif align = gp_align_right :
			pict := pict shifted (- xpart(lrcorner pict),0);
		fi;
		% Hans wanted to persuade me to make the code shorter
		% (zero is replicated three times), but I prefer clarity against sparing
		% two bytes
		
		pict
	enddef;

	def gp_put_text(expr pos, angle, align, str) =
		draw (gp_the_text(align, str) scaled gp_scale_text rotated angle shifted pos) withcolor gp_color_current;
	%	draw bbox ((gp_the_text(align, str) rotated angle shifted pos)) withcolor gp_color_current;
	enddef;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%
	%% drawing and filling
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% low-level interface may change !!!
	picture gp_pattern_image[], gp_pattern_current, gp_pattern_type[];
	numeric gp_num_patterns; gp_num_patterns := 11;
	% TODO: redraw the patterns if necessary (if linewidth changes for example)
	numeric gp_pattern_linewidth; gp_pattern_linewidth := .5gp_scale_linewidth*gp_internal_linewidth;

	% default patterns (PostScript-like)
	%
	% 0: empty
	gp_pattern_image[0] := image(
		setbounds currentpicture to unitsquare;
	);
	% 3: full
	gp_pattern_image[3] := image(
	%	fill unitsquare enlarged .1;
	%	setbounds currentpicture to unitsquare;
		fill fullsquare xyscaled (5cm,5cm);
%		fill fullsquare xyscaled (2.5w,2.5h);
	);
	% 4: \
	gp_pattern_image[4] := image( % TODO!!!
		draw ((1,-1)--(-1,1)) scaled 2mm withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to unitsquare scaled 2mm;
	);
	% 5: /
	gp_pattern_image[5] := image( % TODO!!!
		draw ((-1,-1)--(1,1)) scaled 2mm withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to unitsquare scaled 2mm;
	);
	% 6: \
	gp_pattern_image[6] := image( % TODO!!!
		draw ((1,-2)--(-1,2)) scaled 2mm withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to unitsquare scaled 2mm;
	);
	% 7: /
	gp_pattern_image[7] := image( % TODO!!!
		draw ((-1,-2)--(1,2)) scaled 2mm withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to unitsquare scaled 2mm;
	);
	% 1: 4+5
	gp_pattern_image[1] := image(
		draw gp_pattern_image[4];
		draw gp_pattern_image[5];
	);
	% 2: 4+5, bolj tesno skupaj
	gp_pattern_image[2] := image(
		draw gp_pattern_image[1];
		draw gp_pattern_image[1] shifted (.5bbwidth(gp_pattern_image[1]),0);
	);

	% argument: 2 times radius
	vardef gp_pattern_image_circles(expr d) = image (
		draw fullcircle scaled d withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to fullsquare scaled d;
	) enddef;

	vardef gp_pattern_image_roof(expr d) = image (
		save p; path p; p = fullcircle cutbefore (point 4 of fullcircle);
		draw p scaled d withpen pencircle scaled gp_pattern_linewidth;
		draw p shifted (.5,.5) scaled d withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to unitsquare shifted (0,-.5) scaled d;
	) enddef;

	vardef gp_pattern_image_brick(expr width, height) = image (
%		save p; path p; p = unitsquare shifted (-.25,-.5) scaled;
		draw unitsquare shifted (-.25,-.5) xyscaled (width,height) withpen pencircle scaled gp_pattern_linewidth;
		draw unitsquare shifted ( .25, .5) xyscaled (width,height) withpen pencircle scaled gp_pattern_linewidth;
		setbounds currentpicture to unitsquare yscaled 2 shifted (-.25,-.5) xyscaled (width,height);
	) enddef;

	for i=0 upto 7:
		gp_pattern_type[i] := gp_pattern_image[i];
	endfor;

	gp_pattern_type[8] := gp_pattern_image_circles(2mm);
	gp_pattern_type[9] := gp_pattern_image_roof(1.5mm);
	gp_pattern_type[10] := gp_pattern_image_brick(2mm,1mm);

	% fill a closed path with current color with density "density"
	% (0: background color, 1: current color)
	%
	% TODO (once in the future): fill with smooth shading & pattern fill
	%
	% p - path to be filled
	% density - density of the color (between 0 and 1)
	def gp_fill_dens(expr p, density) =
		fill (p) withcolor density[gp_color_background,gp_color_current];
	enddef;
	% filling with density 1
	def gp_fill(expr p) =
		gp_fill_dens(p,1);
	enddef;
	% TODO: filling with a pattern: not implemented yet (implement approximately 8 patterns)
	def gp_fill_pattern(expr p, pattern) =
		% TODO: WRONG, just a bad temporary solution
		begingroup;
%		save gp_pattern_current; picture gp_pattern_current;
		gp_pattern_current := gp_pattern_type[pattern mod gp_num_patterns];
		% TODO: check if it exists!

		draw image (
			for i=-1 upto 5:
			for j=-1 upto 5:
				draw gp_pattern_current shifted (i*bbwidth(gp_pattern_current),j*bbheight(gp_pattern_current)) shifted llcorner p withcolor gp_color_current;
			endfor;
			endfor;
			clip currentpicture to p;
		);
		endgroup;
%
%		fill (p) withcolor ((pattern mod 8)/8)[gp_color_background,black];
	enddef;

	def gp_draw(expr p) =
		draw (p) withcolor gp_color_current withpen pencircle scaled gp_linewidth
			if gp_use_dashed: dashed gp_dash_linetype(gp_linetype) fi;
	enddef;

	def gp_dot(expr x,y) =
		drawdot shifted (x,y) withcolor gp_color_current withpen pencircle scaled gp_linewidth;
	enddef;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%
	%% Poins & Symbols
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% should we draw the points using metapost or typeset them using TeX?
	newinternal gp_points_with_metapost, gp_points_with_tex;
	gp_points_with_metapost := 0;
	gp_points_with_tex      := 1;

	numeric gp_points_with;
	% default is to draw the points with metapost rather than typeset them
	% with TeX
	gp_points_with := gp_points_with_metapost;

	% the number of point types
	numeric gp_num_points_with_tex, gp_num_points_with_metapost;

	% returns a path representing a closed n-polygon, starting at upper corner (12 o'clock)
	vardef fullpolygon(expr n) =
		(for i=1 upto n: (up rotated ((i-1)*360/n)) -- endfor cycle)
	enddef;

	%-------------------------%
	% point shape definitions %
	%-------------------------%
	path gp_point_shape[];

	% 0 - plus
	gp_point_shape[0] := (0,0)--(-1,0)--(1,0)--(0,0)--(0,1)--(0,-1)--cycle;
	% 1 - X
	gp_point_shape[1] := (0,0)--(-1,-1)--(1,1)--(0,0)--(-1,1)--(1,-1)--cycle;
	% 2 - star (+ & x)
	gp_point_shape[2] :=
		(0,0)--(-1, 0)--(1, 0)--
		(0,0)--(-1,-1)--(1, 1)--
		(0,0)--(-1, 1)--(1,-1)--
		(0,0)--( 0,-1)--(0, 1)--cycle;
	% 3, 4 - box
	gp_point_shape[3] := (-1,-1)--(1,-1)--(1,1)--(-1,1)--cycle;
	gp_point_shape[4] := gp_point_shape[3];
	% 5, 6 - circle
	gp_point_shape[5] := fullcircle scaled 2;
	gp_point_shape[6] := gp_point_shape[5];
	% 7, 8 - triangle
	% scaled is such a way that it's exactly 2 units wide
	gp_point_shape[7] := fullpolygon(3) scaled (1/cosd(30));
	gp_point_shape[8] := gp_point_shape[7];
	% 9, 10 - upside down triangle
	gp_point_shape[9] := gp_point_shape[8] scaled -1;
	gp_point_shape[10] := gp_point_shape[9];
	% 11, 12 - diamond
	gp_point_shape[11] := (-1,0)--(0,-1)--(1,0)--(0,1)--cycle;
	gp_point_shape[12] := gp_point_shape[11];
	% 13, 14 - pentagon
	gp_point_shape[13] := fullpolygon(5) scaled (1/cosd(18));
	gp_point_shape[14] := gp_point_shape[13];

	picture gp_point_pt[];

	for i=0,1,2,3,5,7,9,11,13:
		gp_point_pt[i] := image(draw gp_point_shape[i] scaled 3pt;); % TODO: fix the scale & linewidth
	endfor;
	for i=4,6,8,10,12,14:
		gp_point_pt[i] := image(filldraw gp_point_shape[i] scaled 3pt;); % TODO: fix the scale & linewidth
	endfor;

	% we have defined 15 point types so far
	gp_num_points_with_metapost := 15;

	%-------------------------%

	% n is the number of symbol, but might a be a figure as well
	vardef gp_the_symbol(expr n) =
		picture pict;
		% using metapost
		if numeric n :
			if n = -1 :
				% point type -1 is always a dot
				pict := image( fill fullcircle scaled gp_linewidth; );
			else :
				if gp_points_with = gp_points_with_metapost :
					% TODO
					pict := gp_point_pt[(n mod gp_num_points_with_metapost)];
				else :
					pict := sometxt((n mod gp_num_points_with_tex) + 1 + 500);
					% XXX: 500 is a hack (see m/t-gnuplot.tex) and might need a fix
				fi;
			fi;
		elseif picture n:
			pict := n;
		else:
			pict := nullpicture;
		fi
		pict shifted -center pict
	enddef ;
	% the points have to be scaled slightly more
	def gp_point(expr x, y, n) =
		draw (gp_the_symbol(n) scaled (gp_scale_pointsize) shifted (x,y)) withcolor gp_color_current;
	enddef ;

	endinput

end

