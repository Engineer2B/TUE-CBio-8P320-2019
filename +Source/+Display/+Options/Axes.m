classdef Axes < matlab.mixin.Copyable & Source.Display.Exportable...
	& Source.Display.MultiColorObject
	properties
		% The font size affects the title, axis labels, and tick labels.
		% It also affects any legends or colorbars associated with the axes.
		% The default font size depends on the specific operating system and
		% locale. By default, the font size is measured in points.
		% To change the units, set the FontUnits property.
		% MATLAB automatically scales some of the text to a percentage of the
		% axes font size.
		% Titles and axis labels 110% of the axes font size by default.
		% To control the scaling, use the TitleFontSizeMultiplier and
		% LabelFontSizeMultiplier properties.
		% Legends and colorbars 90% of the axes font size by default.
		% To specify a different font size, set the FontSize property for the
		% Legend or Colorbar object instead.
		Font = Source.Display.Options.ExtendedFont.New()
		XColor
		YColor
		ZColor
		% Ticks
		% Tick values, specified as a vector of increasing values.
		% If you do not want tick marks along the axis, then specify an
		% empty vector [].
		% The tick values are the locations along the axis where the tick
		% marks appear.
		% The tick labels are the labels that you see next to each tick mark.
		% Use the XTickLabels, YTickLabels, and ZTickLabels properties to
		% specify the associated labels.
		XTick = []
		YTick = []
		ZTick = []
		% Selection mode for the tick values, specified as one of these values:
		% 'auto' - Automatically select the tick values based on the range
		% of data for the axis.
		% 'manual' - Manually specify the tick values. To specify the values,
		% set the XTick, YTick, or ZTick property.
		XTickMode = Source.Enum.Mode.auto
		YTickMode = Source.Enum.Mode.auto
		ZTickMode = Source.Enum.Mode.auto
		% Tick labels, specified as a cell array of character vectors or a
		% string array. If you do not want tick labels to show, then specify
		% an empty cell array {}. If you do not specify enough labels for
		% all the ticks values, then the labels repeat.
		% Tick labels support TeX and LaTeX markup.
		% See the TickLabelInterpreter property for more information.
		XTickLabel = ''
		YTickLabel = ''
		ZTickLabel = ''
		XTickLabelMode = Source.Enum.Mode.auto
		YTickLabelMode = Source.Enum.Mode.auto
		ZTickLabelMode = Source.Enum.Mode.auto
		% Tick label interpretation, specified as one of these values:
		% 'tex' - Interpret labels using a subset of TeX markup.
		% 'latex' - Interpret labels using a subset of LaTeX markup.
		% 'none' - Display literal characters.
		TickLabelInterpreter = Source.Enum.Interpreter.Latex
		% Tick label rotation, specified as a numeric value in degrees.
		% Positive values give counterclockwise rotation.
		% Negative values give clockwise rotation.
		XTickLabelRotation = 0
		YTickLabelRotation = 0
		ZTickLabelRotation = 0
		% Minor tick marks, specified as one of these values:
		% 'off' - Do not display minor tick marks. This value is the
		% default for an axis with a linear scale.
		% 'on' - Display minor tick marks between the major tick marks
		% on the axis. The space between the major tick marks determines
		% the number of minor tick marks. This value is the default
		% for an axis with a log scale.
		XMinorTick = Source.Enum.Toggle.Off
		YMinorTick = Source.Enum.Toggle.Off
		ZMinorTick = Source.Enum.Toggle.Off
		% Tick mark direction, specified as one of these values:
		% 'in' - Direct the tick marks inward from the axis lines.
		% (Default for 2-D views)
		% 'out' - Direct the tick marks outward from the axis lines.
		% (Default for 3-D views)
		% 'both' - Center the tick marks over the axis lines.
		TickDir
		% Selection mode for the TickDir property, specified as
		% one of these values:
		% 'auto' - Automatically select the tick direction based
		% on the current view.
		% 'manual' - Manually specify the tick direction.
		% To specify the tick direction, set the TickDir property.
		TickDirMode = Source.Enum.Mode.auto
		% Tick mark length, specified as a two-element vector of
		% the form [2Dlength 3Dlength]. The first element is the 
		% tick mark length in 2-D views and the second element is
		% the tick mark length in 3-D views. Specify the values in
		% units normalized relative to the longest of the visible
		% x-axis, y-axis, or z-axis lines.
		TickLength = [0.01 0.025]
		% Rulers
		XLim
		YLim
		ZLim
		XLimMode = Source.Enum.Mode.auto
		YLimMode = Source.Enum.Mode.auto
		ZLimMode = Source.Enum.Mode.auto
		% x-axis location.
		% This property applies only to 2-D views.
		XAxisLocation = Source.Enum.XAxisLocation.bottom
		% y-axis location.
		% This property applies only to 2-D views.
		YAxisLocation = Source.Enum.YAxisLocation.left
		% Grids
		%  Grid lines, specified as one of these values:
		% 'off' - Do not display the grid lines.
		% 'on' - Display grid lines perpendicular to the axis; for example,
		% along lines of constant x, y, or z values.
		% Alternatively, use the grid on or grid off command to set all
		% three properties to 'on' or 'off', respectively.
		% For more information, see grid.
		XGrid = Source.Enum.Toggle.Off
		YGrid = Source.Enum.Toggle.Off
		ZGrid = Source.Enum.Toggle.Off
		% Placement of grid lines and tick marks in relation to graphic objects,
		% specified as one of these values:
		% 'bottom' - Display tick marks and grid lines under graphics objects.
		% 'top' - Display tick marks and grid lines over graphics objects.
		% This property affects only 2-D views. 
		Layer = Source.Enum.Layer.bottom
		% Line style for grid lines.
		% To display the grid lines, use the grid on command or set the
		% XGrid, YGrid, or ZGrid property to 'on'. 
		GridLineStyle = Source.Enum.LineStyle.Solid
		% Color of grid lines.
		% To display the grid lines, use the grid on command or set the XGrid,
		% YGrid, or ZGrid property to 'on'. 
		GridColor = [0.15 0.15 0.15]
		% Property for setting the grid color, specified as one of these values:
		% 'auto' - Check the values of the XColorMode, YColorMode, and ZColorMode properties
		% to determine the grid line colors for the x, y, and z directions.
		% 'manual' - Use GridColor to set the grid line color for all directions. 
		GridColorMode = Source.Enum.Mode.auto
		% Grid-line transparency, specified as a value in the range [0,1].
		% A value of 1 means opaque and a value of 0 means completely transparent.
		GridAlpha = 0.15
		% Selection mode for the GridAlpha property,specified as one of these
		% values:
		% 'auto' - Default transparency value of 0.15.
		% 'manual' - Manually specify the transparency value.
		% To specify the value, set the GridAlpha.
		GridAlphaMode = Source.Enum.Mode.auto
		% Minor grid lines, specified as one of these values:
		% 'off' - Do not display grid lines.
		% 'on' - Display grid lines aligned with the minor tick marks of the axis.
		% You do not need to enable minor ticks to display minor grid lines.
		% Alternatively, use the grid minor command to toggle the visibility of the
		% minor grid lines. 
		XMinorGrid = Source.Enum.Toggle.Off
		YMinorGrid = Source.Enum.Toggle.Off
		ZMinorGrid = Source.Enum.Toggle.Off
		% Line style for minor grid lines.
		% To display minor grid lines, use the grid minor command or set the
		% XGridMinor, YGridMinor, or ZGridMinor property to 'on'. 
		MinorGridLineStyle = Source.Enum.LineStyle.Dotted
		% Color of minor grid lines.
		% To display minor grid lines, use the grid minor command or set the
		% XGridMinor, YGridMinor, or ZGridMinor property to 'on'.
		MinorGridColor = [0.1 0.1 0.1]
		% Property for setting the minor grid color, specified as one of these
		% values:'auto' - Check the values of the XColorMode, YColorMode, and
		% ZColorMode properties to determine the grid line colors for the x, y, and z
		% directions.'manual' - Use MinorGridColor to set the minor grid line color
		% for all directions. 
		MinorGridColorMode = Source.Enum.Mode.auto
		% Minor grid line transparency, specified as a value in the range [0,1].A
		% value of 1 means opaque and a value of 0 meanscompletely transparent.
		MinorGridAlpha = 0.25
		% Selection mode for the MinorGridAlpha property,specified as one of these
		% values:'auto' - Default transparency value of 0.25.'manual' - Manually
		% specify the transparency value. To specify the value, set the MinorGridAlpha
		MinorGridAlphaMode = Source.Enum.Mode.auto
		% Labels
		% Text object for axes title. To add a title, set the String property of the
		% text object. To change the title appearance, such as the font style or
		% color, set other properties. For a complete list, see Text Properties.ax =
		% gca;ax.Title.String = 'My Title';ax.Title.FontWeight = 'normal';
		% Alternatively, use the title function to add a title and control the
		% appearance.title('My Title','FontWeight','normal') NoteThis text object is
		% not contained in the axes Children property, cannot be returned by findobj,
		% and does not use default values defined for text objects. 
		Title
		% Multiple Plots
		% Color order, specified as a three-column matrix of RGB triplets.
		% Each row of
		% the matrix defines one color in the color order.
		% The default color order has
		% seven colors.
		% Default Color Order Associated RGB Triplets [ 0 0.4470 0.7410
		% 0.8500 0.3250 0.0980 0.9290 0.6940 0.1250 0.4940 0.1840 0.5560 0.4660 0.6740
		% 0.1880 0.3010 0.7450 0.9330 0.6350 0.0780 0.1840]
		% Change Color Order Before
		% Plotting You must change the color order before plotting.
		% Changing the order has no effect on existing plots.
		% However, many graphics functions reset the
		% color order back to the default value before plotting.
		ColorOrder
		% Next color to use in the color order, specified as a positive
		% integer. For example, if this property is set to 1, then the next
		% plot added to the axes uses the first color in the color order. If
		% the index value exceeds the number of colors in the color order, then
		% the index value modulo of the number of colors determines the next
		% color used. If you used a hold on command or if the NextPlot property
		% of the axes is set to 'add', then the color order index value
		% increases every time a new plot is added. Reset the color order by
		% setting the ColorOrderIndex property to 1. 
		ColorOrderIndex = 1
		% Line-style order, specified as a character vector, a cell array of
		% character vectors, or a string array. Create each element using one
		% or more of the line-style specifiers listed in the table. You can
		% combine a line and a marker specifier in a single element, such as
		% '-*'. 
		LineStyleOrder
		% Next line style to use in the line-style order, specified as a
		% positive integer. For example, if this property is set to 1, then the
		% next plot added to the axes uses the first line style in the
		% line-style order. If the index value exceeds the number of line
		% styles in the line-style order, then the index value modulo of the
		% number of line styles determines the next line style used. If you
		% used a hold on command or if the NextPlot property of the axes is set
		% to 'add', then the index value increases every time you add a new
		% plot. Subsequent plots cycle through the line-style order. Reset the
		% line-style order by setting the LineStyleOrderIndex property to 1. 
		LineStyleOrderIndex = 1
		% Order for rendering objects, specified as one of these values:
		% 'depth' - Draw objects in back-to-front order based on the current
		% view. Use this value to ensure that objects in front of other objects
		% are drawn correctly.
		% 'childorder' - Draw objects in the order in which
		% they are created by graphics functions, without considering the
		% relationship of the objects in three dimensions. This value can
		% result in faster rendering, particularly if the figure is very large,
		% but also can result in improper depth sorting of the objects
		% displayed. 
		SortMethod = Source.Enum.SortMethod.childorder
		% Color and Transparency Maps
		% Color map, specified as an m-by-3 array of RGB (red, green, blue)
		% triplets that define m individual colors. 
		Colormap
		% Scale for color mapping, specified as one of these values:
		% 'linear' - Linear scale. The tick values along the colorbar also use
		% a linear scale.
		% 'log' - Log scale. The tick values along the colorbar also use
		% a log scale.
		ColorScale = Source.Enum.Scale.linear
		% Color limits for objects in axes that use the colormap, specified as
		% a two-element vector of the form [cmin cmax]. This property
		% determines how data values map to the colors in the colormap where:
		% cmin specifies the data value that maps to the first color in the
		% colormap.cmax specifies the data value that maps to the last color in
		% the colormap. The Axes object interpolates data values between cmin
		% and cmax across the colormap. Values outside this range use either
		% the first or last color, whichever is closest. 
		CLim = [0 1]
		% Selection mode for the CLim property, specified as one of these
		% values:
		% 'auto' - Automatically select the limits based on the color
		% data of the graphics objects contained in the axes.
		% 'manual' - Manually specify the values. To specify the values,
		% set the CLim property.
		% The values do not change when the limits of the axes
		% children change. 
		CLimMode = Source.Enum.Mode.auto
		% Transparency map, specified as an array of finite alpha values that
		% progress linearly from 0 to 1. The size of the array can be m-by-1 or
		% 1-by-m. MATLAB accesses alpha values by their index in the array.
		% Alphamaps can be any length. 
		Alphamap
		% Scale for transparency mapping, specified as one of these values:
		% 'linear' - Linear scale
		% 'log' - Log scale 
		AlphaScale = Source.Enum.Scale.linear
		% Alpha limits, specified as a two-element vector of the form [amin
		% amax]. This property affects the AlphaData values of graphics
		% objects, such as surface, image, and patch objects. This property
		% determines how the AlphaData values map to the figure alpha map,
		% where: amin specifies the data value that maps to the first alpha
		% value in the figure alpha map.amax specifies the data value that maps
		% to the last alpha value in the figure alpha map. The Axes object
		% interpolates data values between amin and amax across the figure
		% alpha map. Values outside this range use either the first or last
		% alpha map value, whichever is closest. The Alphamap property of the
		% figure contains the alpha map. For more information, see the alpha
		% function. 
		ALim = [0 1]
		% Selection mode for the ALim property, specified as one of these
		% values: 'auto' - Automatically select the limits based on the
		% AlphaData values of the graphics objects contained in the
		% axes.'manual' - Manually specify the alpha limits. To specify the
		% alpha limits, set the ALim property. 
		ALimMode = Source.Enum.Mode.auto
		% Box Styling
		% Background color, specified as an RGB triplet or one of the color
		% options listed in the table. For a custom color, specify an RGB
		% triplet. An RGB triplet is a three-element row vector whose elements
		% specify the intensities of the red, green, and blue components of the
		% color. The intensities must be in the range [0,1]; for example, [0.4
		% 0.6 0.7]. Alternatively, you can specify some common colors by name.
		% This table lists the long and short color name options and the
		% equivalent RGB triplet values. OptionDescriptionEquivalent RGB
		% Triplet'red' or 'r'Red[1 0 0]'green' or 'g'Green[0 1 0]'blue' or
		% 'b'Blue[0 0 1]'yellow' or 'y'Yellow[1 1 0]'magenta' or 'm'Magenta[1 0
		% 1]'cyan' or 'c'Cyan[0 1 1]'white' or 'w'White[1 1 1]'black' or
		% 'k'Black[0 0 0]'none'No colorNot applicable 
		Color = [1 1 1]
		% Line width of axes outline, tick marks, and grid lines, specified as
		% a positive numeric value in point units. One point equals 1/72 inch. 
		LineWidth = 0.5
		% Box outline, specified as 'off' or 'on'. ValueDescription2-D
		% Result3-D Result'off' Do not display the box outline around the axes.
		Box = Source.Enum.Toggle.Off
		% Box outline style, specified as 'back' or 'full'. This property
		% affects only 3-D views. ValueDescriptionResult
		% 'back' Outline the back planes of the 3-D box. 
		BoxStyle = Source.Enum.BoxStyle.back
		% Clipping of objects to the axes limits, specified as either 'on' or
		% 'off'. The clipping behavior of an object within the Axes object
		% depends on both the Clipping property of the Axes object and the
		% Clipping property of the individual object. The property value of the
		% Axes object has these effects:
		% 'on' - Enable each individual object
		% within the axes to control its own clipping behavior based on the
		% Clipping property value for the object.
		% 'off' - Disable clipping for
		% all objects within the axes, regardless of the Clipping property
		% value for the individual objects. Parts of objects can appear outside
		% of the axes limits. For example, parts can appear outside the limits
		% if you create a plot, use the hold on command, freeze the axis
		% scaling, and then add a plot that is larger than the original plot.
		% This table lists the results for different combinations of Clipping
		% property values.
		Clipping = Source.Enum.Toggle.On
		% Clipping boundaries, specified as one of the values in this table. If
		% a plot contains markers, then as long as the data point lies within
		% the axes limits, MATLAB draws the entire marker. The ClippingStyle
		% property has no effect if the Clipping property is set to 'off'.
		% '3dbox' - Clip plotted objects to the six sides of the axes box 
		% defined by the axis limits. Thick lines might display outside the 
		% axes limits.
		% 'rectangle' - Clip plotted objects to a rectangular boundary 
		% enclosing the axes in any given view.
		% Clip thick lines at the axes limits. 
		ClippingStyle = Source.Enum.ClippingStyle.box3d
		% Background light color, specified as an RGB triplet or one of the
		% color options listed in the table. The background light is a
		% directionless light that shines uniformly on all objects in the axes.
		% To add light, use the light function. For a custom color, specify an
		% RGB triplet. An RGB triplet is a three-element row vector whose
		% elements specify the intensities of the red, green, and blue
		% components of the color. The intensities must be in the range [0,1];
		% for example, [0.4 0.6 0.7]. Alternatively, you can specify some
		% common colors by name.
		AmbientLightColor = Source.Enum.Color.Default.w
		% Position
		% Size and location, including the labels and a margin, specified as a
		% four-element vector of the form [left bottom width height]. By
		% default, MATLAB measures the values in units normalized to the
		% container. To change the units, set the Units property. The default
		% value of [0 0 1 1] includes the whole interior of the container. The
		% left and bottom elements define the distance from the lower left
		% corner of the container (typically a figure, panel, or tab) to the
		% lower left corner of the outer position boundary.The width and height
		% elements are the outer position boundary dimensions. These figures
		% show the areas defined by the OuterPosition values (blue) and the
		% Position values (red). 2-D View of Axes3-D View of Axes For more
		% information on the axes position, see Control Axes Layout. 
		OuterPosition = [0 0 1 1]
		% Size and location, excluding a margin for the labels, specified as a
		% four-element vector of the form [left bottom width height]. By
		% default, MATLAB measures the values in units normalized to the
		% container. To change the units, set the Units property. The left and
		% bottom elements define the distance from the lower left corner of the
		% container (typically a figure, panel, or tab) to the lower left
		% corner of the position boundary.The width and height elements are the
		% position boundary dimensions. For axes in a 3-D view, the Position
		% property is the smallest rectangle that encloses the axes. If you
		% want to specify the position and account for the text around the
		% axes, then set the OuterPosition property instead. These figures show
		% the areas defined by the OuterPosition values (blue) and the Position
		% values (red). 2-D View of Axes3-D View of Axes For more information
		% on the axes position, see Control Axes Layout. 
		Position = [0.1300 0.1100 0.7750 0.8150]
		% Active position property during resize operation, specified as one of
		% these values:
		% 'outerposition' - Hold the OuterPosition property
		% constant.
		% 'position' - Hold the Position property constant. A figure
		% can change size if you interactively resize it or during a printing
		% or exporting operation. 
		ActivePositionProperty = Source.Enum.ActivePositionProperty.outerposition
		% Position units, specified as one of these values.
		% (default) Normalized with respect to the
		% container, which is typically the figure or a panel. The lower left
		% corner of the container maps to (0,0) and the upper right corner maps
		% to (1,1). 
		Units = Source.Enum.Units.Normalized
		% Relative length of data units along each axis, specified as a
		% three-element vector of the form [dx dy dz]. This vector defines the
		% relative x, y, and z data scale factors. For example, specifying this
		% property as [1 2 1] sets the length of one unit of data in the
		% x-direction to be the same length as two units of data in the
		% y-direction and one unit of data in the z-direction. Alternatively,
		% use the daspect function to change the data aspect ratio. 
		DataAspectRatio = [1 1 1]
		% Data aspect ratio mode, specified as one of these values:
		% 'auto' - Automatically select values that make best use of the 
		% available space. If PlotBoxAspectRatioMode and CameraViewAngleMode 
		% are also set to 'auto', then enable "stretch-to-fill" behavior.
		% Stretch the axes so that it fills the available space as defined by 
		% the Position property.
		% 'manual' - Disable the "stretch-to-fill" behavior and use the
		% manually specified data aspect ratio. To specify the values, set the
		% DataAspectRatio property. 
		DataAspectRatioMode = Source.Enum.Mode.auto
		% Relative length of each axis, specified as a three-element vector of
		% the form [px py pz] defining the relative x-axis, y-axis, and z-axis
		% scale factors. The plot box is a box enclosing the axes data region
		% as defined by the axis limits. Alternatively, use the pbaspect
		% function to change the data aspect ratio. If you specify the axis
		% limits, data aspect ratio, and plot box aspect ratio, then MATLAB
		% ignores the plot box aspect ratio. It adheres to the axis limits and
		% data aspect ratio. 
		PlotBoxAspectRatio = [1 1 1]
		% Selection mode for the PlotBoxAspectRatio property, specified as one
		% of these values:
		% 'auto' - Automatically select values that make best
		% use of the available space. If DataAspectRatioMode and
		% CameraViewAngleMode also are set to 'auto', then enable
		% "stretch-to-fill" behavior. Stretch the Axes object so that it fills
		% the available space as defined by the Position property.
		% 'manual' - Disable the "stretch-to-fill" behavior and use the
		% manually specified plot box aspect ratio. To specify the values, set 
		% the PlotBoxAspectRatio property. 
		PlotBoxAspectRatioMode = Source.Enum.Mode.manual
		% View
		% Azimuth and elevation of view, specified as a two-element vector of
		% the form [azimuth elevation] defined in degree units. Alternatively,
		% use the view function to set the view. 
		View = [0 90]
		% Type of projection onto a 2-D screen, specified as one of these
		% values:
		% 'orthographic' - Maintain the correct relative dimensions of
		% graphics objects regarding the distance of a given point from the
		% viewer, and draw lines that are parallel in the data parallel on the
		% screen.
		% 'perspective' - Incorporate foreshortening, which enables you
		% to perceive depth in 2-D representations of 3-D objects. Perspective
		% projection does not preserve the relative dimensions of objects.
		% Instead, it displays a distant line segment smaller than a nearer
		% line segment of the same length. Lines that are parallel in the data
		% might not appear parallel on screen. 
		Projection = Source.Enum.Projection.orthographic
		% Camera location, or the viewpoint, specified as a three-element
		% vector of the form [x y z]. This vector defines the axes coordinates
		% of the camera location, which is the point from which you view the
		% axes. The camera is oriented along the view axis, which is a straight
		% line that connects the camera position and the camera target. For an
		% illustration, see Camera Graphics Terminology. If the Projection
		% property is set to 'perspective', then as you change the
		% CameraPosition setting, the amount of perspective also changes.
		% Alternatively, use the campos function to set the camera location. 
		CameraPosition
		% Selection mode for the CameraPosition property, specified as one of
		% these values:
		% 'auto' - Automatically set CameraPosition along the
		% view axis. Calculate the position so that the camera lies a fixed
		% distance from the target along the azimuth and elevation specified by
		% the current view, as returned by the view function. Functions like
		% rotate3d, zoom, and pan, change this mode to 'auto' to perform their
		% actions.
		% 'manual' - Manually specify the value. To specify the value,
		% set the CameraPosition property. 
		CameraPositionMode = Source.Enum.Mode.auto
		% Camera target point, specified as a three-element vector of the form
		% [x y z]. This vector defines the axes coordinates of the point. The
		% camera is oriented along the view axis, which is a straight line that
		% connects the camera position and the camera target. For an
		% illustration, see Camera Graphics Terminology. Alternatively, use the
		% camtarget function to set the camera target. 
		CameraTarget
		% Selection mode for the CameraTarget property, specified as one of
		% these values:
		% 'auto' - Position the camera target at the centroid of
		% the axes plot box.
		% 'manual' - Use the manually specified camera target value.
		% To specify a value, set the CameraTarget property. 
		CameraTargetMode = Source.Enum.Mode.auto
		% Vector defining upwards direction, specified as a three-element
		% direction vector of the form [x y z]. For 2-D views, the default
		% value is [0 1 0]. For 3-D views, the default value is [0 0 1]. For an
		% illustration, see Camera Graphics Terminology. Alternatively, use the
		% camup function to set the upwards direction. 
		CameraUpVector
		% Selection mode for the CameraUpVector property, specified as one of
		% these values:
		% 'auto' - Automatically set the value to [0 0 1] for 3-D
		% views so that the positive z-direction is up. Set the value to [0 1
		% 0] for 2-D views so that the positive y-direction is up.
		% 'manual' - Manually specify the vector defining the upwards
		% direction. To specify a value, set the CameraUpVector property. 
		CameraUpVectorMode = Source.Enum.Mode.auto
		% Field of view, specified as a scalar angle greater than 0 and less
		% than or equal to 180. Changing the camera view angle affects the size
		% of graphics objects displayed in the axes, but does not affect the
		% degree of perspective distortion. The greater the angle, the larger
		% the field of view and the smaller objects appear in the scene. For an
		% illustration, see Camera Graphics Terminology. 
		CameraViewAngle = 6.6086
		% Selection mode for the CameraViewAngle property, specified as one of
		% these values:
		% 'auto' - Automatically select the field of view as the minimum angle
		% that captures the entire scene, up to 180 degrees.
		% 'manual' - Manually specify the field of view. To specify a
		% value, set the CameraViewAngle property. 
		CameraViewAngleMode = Source.Enum.Mode.auto
		% Interactivity
		% State of visibility, specified as one of these values:
		% 'on' - Display the object.
		% 'off' - Hide the object without deleting it. You still can
		% access the properties of an invisible object. 
		Visible = Source.Enum.Toggle.On
		% Identifiers
		% Tag to associate with the axes object, specified as a character
		% vector or string scalar. Use this property to find axes objects in a
		% hierarchy. For example, you can use the findobj function to find axes
		% objects that have a specific Tag property value. 
		Tag
		% User data to associate with the axes object, specified as any MATLAB
		% data, for example, a scalar, vector, matrix, cell array, character
		% array, table, or structure. MATLAB does not use this data. To
		% associate multiple sets of data or to attach a field name to the
		% data, use the getappdata and setappdata functions. 
		UserData = []
	end
	methods(Access = public, Static)
		function obj = New()
			obj = Source.Display.Options.Axes();
		end
	end
	methods
		function set.Color(this, colorIn)
			this.Color = this.convertColor(colorIn, 'Color');
		end
			function set.XColor(this, xColorIn)
				this.XColor = this.convertColor(xColorIn, 'XColor');
			end
			function set.YColor(this, yColorIn)
				this.YColor = this.convertColor(yColorIn, 'YColor');
			end
			function set.ZColor(this, zColorIn)
				this.ZColor = this.convertColor(zColorIn, 'ZColor');
			end
	end
	methods(Access = public)
		function cellObject = ToCell(this)
			this.OutputCell = {'XTickMode', char(this.XTickMode),...
				'YTickMode', char(this.YTickMode),...
				'ZTickMode', char(this.ZTickMode),...
				'XTickLabelMode', char(this.XTickLabelMode),...
				'YTickLabelMode', char(this.YTickLabelMode),...
				'ZTickLabelMode', char(this.ZTickLabelMode),...
				'TickLabelInterpreter', char(this.TickLabelInterpreter),...
				'XTickLabelRotation', this.XTickLabelRotation,...
				'YTickLabelRotation', this.YTickLabelRotation,...
				'ZTickLabelRotation', this.ZTickLabelRotation,...
				'XMinorTick', char(this.XMinorTick),...
				'YMinorTick', char(this.YMinorTick),...
				'ZMinorTick', char(this.ZMinorTick),...
				'TickDirMode', char(this.TickDirMode),...
				'TickLength', this.TickLength,...
				'XLimMode', char(this.XLimMode),...
				'YLimMode', char(this.YLimMode),...
				'ZLimMode', char(this.ZLimMode),...
				'XAxisLocation', char(this.XAxisLocation),...
				'YAxisLocation', char(this.YAxisLocation),...
				'XGrid', char(this.XGrid),...
				'YGrid', char(this.YGrid),...
				'ZGrid', char(this.ZGrid),...
				'Layer', char(this.Layer),...
				'GridLineStyle', char(this.GridLineStyle),...
				'GridColor', this.GridColor,...
				'GridColorMode', char(this.GridColorMode),...
				'GridAlpha', this.GridAlpha,...
				'GridAlphaMode', char(this.GridAlphaMode),...
				'XMinorGrid', char(this.XMinorGrid),...
				'YMinorGrid', char(this.YMinorGrid),...
				'ZMinorGrid', char(this.ZMinorGrid),...
				'MinorGridLineStyle', char(this.MinorGridLineStyle),...
				'MinorGridColor', this.MinorGridColor,...
				'MinorGridColorMode', char(this.MinorGridColorMode),...
				'MinorGridAlpha', this.MinorGridAlpha,...
				'MinorGridAlphaMode', char(this.MinorGridAlphaMode),...
				'Title', this.Title,...
				'ColorOrderIndex', this.ColorOrderIndex,...
				'LineStyleOrderIndex', this.LineStyleOrderIndex,...
				'SortMethod', char(this.SortMethod),...
				'ColorScale', char(this.ColorScale),...
				'CLim', this.CLim,...
				'CLimMode', char(this.CLimMode),...
				'AlphaScale', char(this.AlphaScale),...
				'ALim', this.ALim,...
				'ALimMode', char(this.ALimMode),...
				'Color', this.Color,...
				'LineWidth', this.LineWidth,...
				'Box', char(this.Box),...
				'BoxStyle', char(this.BoxStyle),...
				'Clipping', char(this.Clipping),...
				'ClippingStyle', char(this.ClippingStyle),...
				'AmbientLightColor', char(this.AmbientLightColor),...
				'OuterPosition', this.OuterPosition,...
				'Position', this.Position,...
				'ActivePositionProperty', char(this.ActivePositionProperty),...
				'Units', char(this.Units),...
				'DataAspectRatio', this.DataAspectRatio,...
				'DataAspectRatioMode', char(this.DataAspectRatioMode),...
				'PlotBoxAspectRatio', this.PlotBoxAspectRatio,...
				'PlotBoxAspectRatioMode', char(this.PlotBoxAspectRatioMode),...
				'View', this.View,...
				'Projection', char(this.Projection),...
				'CameraPositionMode', char(this.CameraPositionMode),...
				'CameraTargetMode', char(this.CameraTargetMode),...
				'CameraUpVectorMode', char(this.CameraUpVectorMode),...
				'CameraViewAngle', this.CameraViewAngle,...
				'CameraViewAngleMode', char(this.CameraViewAngleMode),...
				'Visible', char(this.Visible),...
				'UserData', this.UserData};
			this.AddTextIfNonEmpty('XTickLabel', this.XTickLabel);
			this.AddTextIfNonEmpty('YTickLabel', this.YTickLabel);
			this.AddTextIfNonEmpty('ZTickLabel', this.ZTickLabel);
			this.AddIfNonEmpty('XTick', this.XTick);
			this.AddIfNonEmpty('YTick', this.YTick);
			this.AddIfNonEmpty('ZTick', this.ZTick);
			this.AddIfNonEmpty('XLim', this.XLim);
			this.AddIfNonEmpty('YLim', this.YLim);
			this.AddIfNonEmpty('ZLim', this.ZLim);
			this.AddIfNonEmpty('XColor', this.XColor);
			this.AddIfNonEmpty('YColor', this.YColor);
			this.AddIfNonEmpty('ZColor', this.ZColor);
			this.AddIfNonEmpty('TickDir', char(this.TickDir));
			this.AddIfNonEmpty('ColorOrder', this.ColorOrder);
			this.AddIfNonEmpty('LineStyleOrder', this.LineStyleOrder);
			this.AddIfNonEmpty('Colormap', this.Colormap);
			this.AddIfNonEmpty('Alphamap', this.Alphamap);
			this.AddIfNonEmpty('CameraPosition', this.CameraPosition);
			this.AddIfNonEmpty('CameraTarget', this.CameraTarget);
			this.AddIfNonEmpty('CameraUpVector', this.CameraUpVector);
			this.AddIfNonEmpty('Tag', this.Tag);
			this.OutputCell = [this.OutputCell, this.Font.ToCell()];
			cellObject = this.OutputCell;
		end
	end
end