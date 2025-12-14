classdef final_exported_last < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure  matlab.ui.Figure
        VersionLabel  matlab.ui.control.Label
        Button_10         matlab.ui.control.Button
        ROITextArea       matlab.ui.control.TextArea
        ROITextAreaLabel  matlab.ui.control.Label
        Label_4           matlab.ui.control.Label
        EditField         matlab.ui.control.EditField
        Label_3           matlab.ui.control.Label
        Button_9          matlab.ui.control.Button
        Button_8          matlab.ui.control.Button
        Button_7          matlab.ui.control.Button
        Button_6          matlab.ui.control.Button
        Button_5          matlab.ui.control.Button
        Button_4          matlab.ui.control.Button
        Button_3          matlab.ui.control.Button
        Slider            matlab.ui.control.Slider
        SliderLabel       matlab.ui.control.Label
        Button_2          matlab.ui.control.Button
        Label_2           matlab.ui.control.Label
        DICOMLabel        matlab.ui.control.Label
        Label             matlab.ui.control.Label
        Button            matlab.ui.control.Button
        UIAxes2           matlab.ui.control.UIAxes
        UIAxes            matlab.ui.control.UIAxes
    end

    properties (Access = private)
        selectedFolder % Description
        SortedFilePaths     % 存储排序后的文件路径
        img % Description
        idx % Description
        mask % Description
        isDicom % Description
        LastValidText % Description
    end

    methods (Access = public)
        ...existing code...
    end

    % Callbacks that handle component events
    methods (Access = private)
        ...existing code...
    end

    % Component initialization
    methods (Access = private)
        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.IntegerHandle = 'on';
            app.UIFigure.Position = [100 100 800 800];
            app.UIFigure.Name = 'DICOM Processer';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.FontSize = 1;
            app.UIAxes.Position = [24 475 358 268];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontWeight = 'bold';
            app.UIAxes2.XGrid = 'on';
            app.UIAxes2.YGrid = 'on';
            app.UIAxes2.FontSize = 1;
            app.UIAxes2.Position = [382 466 321 277];

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed2, true);
            app.Button.Position = [344 747 75 26];
            app.Button.Text = '选择文件夹';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Position = [2 742 343 36];
            app.Label.Text = '路径';

            % Create DICOMLabel
            app.DICOMLabel = uilabel(app.UIFigure);
            app.DICOMLabel.HorizontalAlignment = 'center';
            app.DICOMLabel.FontSize = 14;
            app.DICOMLabel.FontWeight = 'bold';
            app.DICOMLabel.Position = [201 779 454 22];
            app.DICOMLabel.Text = 'DICOM文件夹的影像数据分析及特征提取';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Position = [436 742 204 25];
            app.Label_2.Text = '结果';

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.Position = [703 707 99 36];
            app.Button_2.Text = '均值滤波';

            % Create SliderLabel
            app.SliderLabel = uilabel(app.UIFigure);
            app.SliderLabel.HorizontalAlignment = 'right';
            app.SliderLabel.Position = [25 454 36 22];
            app.SliderLabel.Text = 'Slider';

            % Create Slider
            app.Slider = uislider(app.UIFigure);
            app.Slider.Limits = [1 200];
            app.Slider.ValueChangedFcn = createCallbackFcn(app, @SliderValueChanged2, true);
            app.Slider.Position = [82 463 193 7];
            app.Slider.Value = 1;

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.Position = [704 672 98 36];
            app.Button_3.Text = '中值滤波';

            % Create Button_4
            app.Button_4 = uibutton(app.UIFigure, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @Button_4Pushed, true);
            app.Button_4.Position = [705 633 97 40];
            app.Button_4.Text = '高斯滤波';

            % Create Button_5
            app.Button_5 = uibutton(app.UIFigure, 'push');
            app.Button_5.ButtonPushedFcn = createCallbackFcn(app, @Button_5Pushed, true);
            app.Button_5.Position = [24 241 134 28];
            app.Button_5.Text = '阈值分割';

            % Create Button_6
            app.Button_6 = uibutton(app.UIFigure, 'push');
            app.Button_6.ButtonPushedFcn = createCallbackFcn(app, @Button_6Pushed, true);
            app.Button_6.Position = [24 215 134 26];
            app.Button_6.Text = '大津阈值';

            % Create Button_7
            app.Button_7 = uibutton(app.UIFigure, 'push');
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @Button_7Pushed, true);
            app.Button_7.Position = [201 241 98 28];
            app.Button_7.Text = '聚类分割';

            % Create Button_8
            app.Button_8 = uibutton(app.UIFigure, 'push');
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @Button_8Pushed, true);
            app.Button_8.Position = [201 97 98 28];
            app.Button_8.Text = '边缘检测';

            % Create Button_9
            app.Button_9 = uibutton(app.UIFigure, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @Button_9Pushed, true);
            app.Button_9.Position = [487 414 113 40];
            app.Button_9.Text = '区域增长';

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [201 207 137 22];
            app.Label_3.Text = '请输入聚类簇数，正整数';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.Position = [353 204 41 27];
            app.EditField.Value = '3';

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'center';
            app.Label_4.Position = [490 388 110 27];
            app.Label_4.Text = '状态监测';

            % Create ROITextAreaLabel
            app.ROITextAreaLabel = uilabel(app.UIFigure);
            app.ROITextAreaLabel.HorizontalAlignment = 'right';
            app.ROITextAreaLabel.FontSize = 16;
            app.ROITextAreaLabel.Position = [383 354 66 22];
            app.ROITextAreaLabel.Text = 'ROI特征';

            % Create ROITextArea
            app.ROITextArea = uitextarea(app.UIFigure);
            app.ROITextArea.ValueChangingFcn = createCallbackFcn(app, @ROITextAreaValueChanging, true);
            app.ROITextArea.FontSize = 16;
            app.ROITextArea.FontWeight = 'bold';
            app.ROITextArea.Position = [464 78 145 300];
            app.ROITextArea.Value = {'请先进行分割'};

            % Create Button_10
            app.Button_10 = uibutton(app.UIFigure, 'push');
            app.Button_10.ButtonPushedFcn = createCallbackFcn(app, @Button_10Pushed, true);
            app.Button_10.Position = [402 241 53 113];
            app.Button_10.Text = '计算';

            % Create VersionLabel
            app.VersionLabel = uilabel(app.UIFigure);
            app.VersionLabel.HorizontalAlignment = 'center';
            app.VersionLabel.FontWeight = 'bold';
            app.VersionLabel.Position = [25 16 748 31];
            app.VersionLabel.Text = '医学影像分析系统    V1.6     2025年12月18日';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)
        % Construct app
        function app = final_exported_last
            % Create UIFigure and components
            createComponents(app)
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end
        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
