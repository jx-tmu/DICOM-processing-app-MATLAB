classdef final_exported_last_desens < matlab.apps.AppBase

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

        function updateImage(app, idx)
            % 显示指定索引的图像
            if isempty(app.SortedFilePaths)
                return; % 如果文件路径为空，直接返回
            end
            app.idx = idx;
            %             app.img = double(dicomread(app.SortedFilePaths{idx}));
            if app.isDicom(idx)
                app.img = double(dicomread(app.SortedFilePaths{idx}));
            else
                imgTmp = imread(app.SortedFilePaths{idx});
                if size(imgTmp,3) == 3
                    imgTmp = rgb2gray(imgTmp);
                end
                app.img = double(imgTmp);
            end
            imshow(app.img, [], 'Parent', app.UIAxes); % 修改为使用 UIAxes
            app.SliderLabel.Text = sprintf('图像 %d / %d', idx, length(app.SortedFilePaths)); % 修改为使用 SliderLabel
            app.Slider.Value = idx;
        end

        function processFolder(app, folderPath)
            % 处理DICOM等文件夹
            exts = {'.dcm', '.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff'};
            fileList = dir(fullfile(folderPath, '*'));
            fileNames = {fileList.name};
            fileNames = fileNames(3:end); % 跳过 '.' 和 '..'

            % 获取完整路径
            fullPaths = fullfile(folderPath, fileNames);

            % 提取InstanceNumber并排序
            instanceNumbers = zeros(length(fullPaths), 1);
            isDicom = false(length(fullPaths), 1);
            for i = 1:length(fullPaths)
                [~, ~, ext] = fileparts(fullPaths{i});
                if strcmpi(ext, '.dcm')
                    try
                        info = dicominfo(fullPaths{i});
                        instanceNumbers(i) = info.InstanceNumber;
                        isDicom(i) = true;
                    catch
                        instanceNumbers(i) = Inf;
                    end
                elseif any(strcmpi(ext, exts(2:end)))
                    instanceNumbers(i) = i + 1e4; % 普通图片排在DICOM后面
                else
                    instanceNumbers(i) = Inf; % 其他文件无效
                end
            end

            [~, sortedIdx] = sort(instanceNumbers);
            app.SortedFilePaths = fullPaths(sortedIdx);
            app.isDicom = isDicom(sortedIdx);
            % 移除无效文件（InstanceNumber为Inf的）
            %             app.SortedFilePaths(isinf(instanceNumbers(sortedIdx))) = [];
            validMask = ~isinf(instanceNumbers(sortedIdx));
            app.SortedFilePaths = app.SortedFilePaths(validMask);
            app.isDicom = app.isDicom(validMask);
            % 设置滑动条范围
            app.Slider.Limits = [0, max(1, length(app.SortedFilePaths))]; % 修改为使用 Slider

            % 显示第一张图像
            if ~isempty(app.SortedFilePaths)
                updateImage(app, 1);
            end
        end
        %         function mask = regionGrow2Seeds(app, I, seed1, seed2, T)
        %             count = 0;
        %             mask = zeros(size(I));
        %             x1 = seed1(2); y1 = seed1(1);
        %             x2 = seed2(2); y2 = seed2(1);
        %             seedVal1 = I(x1, y1);
        %             seedVal2 = I(x2, y2);
        %             mask(x1, y1) = 1;
        %             mask(x2, y2) = 1;
        %             grow = [x1, y1; x2, y2];
        %             while ~isempty(grow)
        %                 count = count+1;
        %                 disp(count)
        %                 current = grow(1,:);
        %                 nearby = eight(current);
        %                 for i = 1:8
        %                     x = nearby(i,1); y = nearby(i,2);
        %                     if x < 1 || y < 1 || x > size(I,1) || y > size(I,2)
        %                         continue;
        %                     end
        %                     f8 = I(x, y);
        %                     d1 = abs(x-x1) + abs(y-y1);
        %                     d2 = abs(x-x2) + abs(y-y2);
        %                     if d1 <= d2
        %                         seed = seedVal1;
        %                     else
        %                         seed = seedVal2;
        %                     end
        %                     if (abs(f8 - seed) < T) && mask(x, y) == 0
        %                         mask(x, y) = 1;
        %                         grow = [grow; x, y];
        %                     end
        %                     if mod(count,100)==0
        %                     imshow(mask,[], 'Parent', app.UIAxes2);
        %                     end
        %                 end
        %
        %                 grow = grow(2:end, :);
        %             end
        %
        %             function nearby = eight(current)
        %                 x1 = current(1); y1 = current(2);
        %                 nearby = [x1-1 y1-1; x1-1 y1; x1-1 y1+1; x1 y1-1; x1 y1+1; x1+1 y1-1; x1+1 y1; x1+1 y1+1];
        %             end
        %         end

        % 8-邻域坐标偏移
        function neigh = get8Neighbors(~)
            neigh = [-1 -1; -1 0; -1 1;
                0 -1;        0 1;
                1 -1;  1 0;  1 1];
        end

        % 单/多点区域生长（核心逻辑，照搬原脚本）
        function mask = regionGrowMultiSeeds(app, img, seeds, T0)
            % img: double 2-D; seeds: N×2 [x,y] 整型；T0: 初始阈值
            [H,W] = size(img);
            mask  = zeros(H,W,'like',img);
            label = 0;
            neigh = app.get8Neighbors();

            for k = 1:size(seeds,1)
                sx = seeds(k,1);  sy = seeds(k,2);
                if sx<1||sx>W||sy<1||sy>H, continue; end
                label = label + 1;
                queue = [sy,sx];          % 用[y,x] 方便矩阵索引
                mask(sy,sx) = label;

                while ~isempty(queue)
                    cy = queue(1,1); cx = queue(1,2);
                    queue(1,:) = [];

                    % 自适应阈值
                    pixVal  = img(mask==label);
                    mu      = mean(pixVal);
                    sigma   = std(pixVal);
                    T       = max(2*sigma, T0);   % 保底 T0
                    if T==0, T = 150; end

                    for n = 1:size(neigh,1)
                        ny = cy + neigh(n,1);
                        nx = cx + neigh(n,2);
                        if ny<1||ny>H||nx<1||nx>W, continue; end
                        if mask(ny,nx)==0 && abs(img(ny,nx)-mu)<T
                            mask(ny,nx) = label;
                            queue(end+1,:) = [ny,nx];
                        end
                    end
                end
            end
            mask = mask>0;   % 返回二值掩膜
        end

        % 让用户连续点击，按右键或回车结束
        function seeds = collectSeeds(app, UIAxes)
            seeds = [];
            title(app.UIAxes, '左键点击选种子，右键或双击结束');
            hold(app.UIAxes, 'on');
            while true
                h = drawpoint(app.UIAxes, 'Color', 'r');
                if isempty(h) || isempty(h.Position)
                    break;
                end
                pos = round(h.Position); % [x, y]
                seeds(end+1, :) = pos;
                % 可选：显示点
                plot(app.UIAxes, pos(1), pos(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
                % 判断是否继续（可通过右键或双击结束，drawpoint会自动退出）
                answer = questdlg('继续添加种子点吗？', '提示', '是', '否', '否');
                if strcmp(answer, '否')
                    break;
                end
            end
            hold(app.UIAxes, 'off');

        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: Button
        function ButtonPushed2(app, event)
            app.selectedFolder = uigetdir('请选择文件夹');

            % 检查用户是否取消了选择
            if app.selectedFolder == 0
                % 用户取消了选择
                app.Label.Text = '用户取消了选择';
            else
                % 用户选择了文件夹，将路径显示在标签上
                app.Label.Text = app.selectedFolder;
                % 处理文件夹中的DICOM文件
                processFolder(app, app.selectedFolder);
            end
        end

        % Value changed function: Slider
        function SliderValueChanged2(app, event)

            if isempty(app.SortedFilePaths)
                disp('空值');
            end
            app.idx = round(app.Slider.Value);
            updateImage(app, app.idx);


        end

        % Button pushed function: Button_2
        function Button_2Pushed(app, event)
            % 均值
            junzhi = imfilter(app.img, fspecial('average',[7 7]), 'replicate');
            imshow(junzhi, [], 'Parent', app.UIAxes2);
        end

        % Button pushed function: Button_3
        function Button_3Pushed(app, event)
            % 中值
            zhongzhi = medfilt2(app.img, [7 7], 'symmetric');
            imshow(zhongzhi, [], 'Parent', app.UIAxes2);
        end

        % Button pushed function: Button_4
        function Button_4Pushed(app, event)
            gaosi = imgaussfilt(app.img,0.7);
            imshow(gaosi, [], 'Parent', app.UIAxes2);
        end

        % Button pushed function: Button_5
        function Button_5Pushed(app, event)
            level = 0.32;                      % 0~1 之间
            img11 = app.img;
            img11 = mat2gray(img11);
            yuzhi = im2bw(img11, level);
            imshow(yuzhi, [], 'Parent', app.UIAxes2);
        end

        % Button pushed function: Button_6
        function Button_6Pushed(app, event)
            img11 = app.img;
            img11 = mat2gray(img11);
            level = graythresh(img11);
            dajin = im2bw(img11, level);
            imshow(dajin, [], 'Parent', app.UIAxes2);
            %             title(fprintf('level:%.2f',level))
        end

        % Button pushed function: Button_7
        function Button_7Pushed(app, event)
            X = double(reshape(app.img, [], size(app.img,3)));   % 多通道拉成 N×p
            [idx1, C] = kmeans(X, str2num(app.EditField.Value), 'Replicates',5);
            L = reshape(idx1, size(app.img,1), size(app.img,2));
            imshow(L, [], 'Parent', app.UIAxes2);
            colormap(app.UIAxes2, jet(str2num(app.EditField.Value)));
        end

        % Button pushed function: Button_8
        function Button_8Pushed(app, event)
            bianyuan = edge(app.img, 'Canny',[],2.5);
            imshow(bianyuan, [], 'Parent', app.UIAxes2);

        end

        % Button pushed function: Button_9
        function Button_9Pushed(app, event)
            img = double(app.img);
            app.Label_4.Text = '正在处理...';
            drawnow;
            % 1. 让用户在 UIAxes 上任意点种子
            seeds = app.collectSeeds(app.UIAxes);
            if isempty(seeds)
                uialert(app.UIFigure, '未选择任何种子', '提示');
                app.Label_4.Text = '处理取消';
                return
            end

            % 2. 运行区域生长
            T0 = 30;                           % 与旧脚本一致
            mask = app.regionGrowMultiSeeds(img, seeds, T0);

            % 3. 结果叠加显示
            cla(app.UIAxes2);
            imshow(app.img, 'Parent', app.UIAxes2); hold(app.UIAxes2, 'on');
            contour(app.UIAxes2, mask, [0.5 0.5], 'Color', 'r', 'LineWidth', 2);
            title(app.UIAxes2, '肺实质掩膜');
            hold(app.UIAxes2, 'off');

            % 4. 把掩膜存到 App 属性，供后续保存/计算
            app.mask = mask;
            app.Label_4.Text = '处理完成';
            drawnow;
            imshow(app.img, [], 'Parent', app.UIAxes);
        end

        % Button pushed function: Button_10
        function Button_10Pushed(app, event)
            if isempty(app.mask)
                app.ROITextArea.Value = {'请先分割并生成掩膜！'};
                return;
            end
            stats = regionprops(app.mask, 'all');
            if isempty(stats)
                app.ROITextArea.Value = {'未检测到ROI区域！'};
                return;
            end
            % 只显示第一个区域的主要特征
            s = stats(1);
            info = {
                ['面积: ', num2str(s.Area)]
                ['质心: ', num2str(s.Centroid(1), '%.2f') ]
                ['      ' num2str(s.Centroid(2), '%.2f')]
                ['YOLO框: ', mat2str(s.BoundingBox)]
                ['周长: ', num2str(s.Perimeter)]
                ['偏心率: ', num2str(s.Eccentricity, '%.2f')]
                ['主轴: ', num2str(s.MajorAxisLength)]
                ['副轴: ', num2str(s.MinorAxisLength)]
                };
            app.ROITextArea.Value = info;
            app.ROITextArea.Value = info; % 在文本区域显示详细信息

            app.LastValidText = info; % 同步更新合法文本
        end

        % Callback function: ROITextArea
        function ROITextAreaValueChanging(app, event)

            newText = event.Value; % 用户输入后的新文本
            if ~isequal(newText, app.LastValidText)
                % 恢复合法文本，确保类型正确
                val = app.LastValidText;
                disp(val)
                if ischar(val)
                    app.ROITextArea.Value = {val};
                elseif isstring(val)
                    app.ROITextArea.Value = cellstr(val);
                elseif iscell(val)
                    if isvector(val) && all(cellfun(@ischar, val))
                        app.ROITextArea.Value = val;
                    else
                        app.ROITextArea.Value = cellfun(@char, val, 'UniformOutput', false);
                    end
                else
                    app.ROITextArea.Value = {char(val)};
                end
                % 弹出警告
                uialert(app.DICOMProcesser2322023391610UIFigure, '禁止篡改数据！', '警告', 'Icon', 'warning');
                app.ROITextArea.BackgroundColor = [1 0.9 0.9]; % 淡红色背景
                pause(1.5);
                app.ROITextArea.BackgroundColor = [1 1 1]; % 恢复白色
            end
        end
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
        function app = final_exported_last_desens
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
