clc
clear all
%本代码用于统计所有纳入患者的年龄和性别
bechmark_date=datetime('2015-12-31');%基准日期是2015年12月31日
filename = 'D:\FCM202601\疾病人为筛选过程\张凯—胸部疾病分类.xlsx'; % 疾病归类
[~, sheetNames] = xlsfinfo(filename);
numSheets = length(sheetNames);
keys=sheetNames;
values={};
for i = 1:length(sheetNames)
    values{i} = table2cell(readtable(filename, 'Sheet', sheetNames{i},'ReadVariableNames',false));
end

%处理cell，去掉每一个元素前后的单引号
for index=1:numel(values)
    if index~=1
    temp=values{index};
    for index1=1:numel(temp)
       temp{index1}= strrep(temp{index1}, '''', '');
    end
    values{index}=temp;
    end
end


%读取原始疾病诊断记录
original_data=table2cell(readtable('D:\FCM202601\呼吸科数据2016-2020.csv'));
copy_original_data=original_data;

% 筛选第7列为'主要诊断'的数据
targetCity = '主要诊断';
columnIndex = 7;

% 方法1：使用 strcmp（精确匹配字符串）
isBeijing = strcmp(copy_original_data(:, columnIndex), targetCity);
filteredData = copy_original_data(isBeijing, :);

%替换疾病名称
deleted_row_number=[];
for index1=1:size(filteredData,1)
    address=filteredData{index1,12};
    current_disease_name=filteredData{index1,6};
    %查找这种疾病名称的位置
%     if index1==84
%         disp('ssssssssssss')
%     end
    if isempty(strfind(address,'上海'))~=1
        for category_index=1:numel(values)
            if category_index~=1 
                isInCell = ismember(current_disease_name, values{category_index});
                if isInCell==1
                    %替换成找到的疾病
                    filteredData{index1,6}=keys{category_index};
                    break;
                end
            end

        end
    else
         %不包含上海，则删除本行（记录行号，后边一次删除）
        deleted_row_number=[deleted_row_number index1];
    end
    
end

%删除不要的行
filteredData(deleted_row_number, :) = [];


male_number=zeros(3653,14);%一共3288天，13种疾病
female_number=zeros(3653,14);%一共3288天，13种疾病
age={};

for index1=1:3653
    for index2=1:14
        age{index1,index2}=[];
    end
end

%替换完疾病之后，将filteredData按照日期进行统计
dateSeries1 = datetime(2016,1,1):datetime(2025,12,31);
for index1=1:size(filteredData,1)
    inhospitaldate=filteredData{index1,11};%入院日期
    %把入院日期变成date类型
    spaceposition=strfind(inhospitaldate,' ');%找到空格
    specificdate=inhospitaldate(1:spaceposition-1);
    Datestring = strrep(specificdate, '/','-');%分割年月日
    currentdatetime=datetime(Datestring);
    
    currentyear=year(currentdatetime);
    if currentyear>=2016 && currentyear<=2025%仅仅计算2016-2025的日期
       %找到修改过的疾病为第几种疾病(keys中的元素序号)
       disease_index=find(strcmp(keys,filteredData{index1,6})==1);
       passdays=days(currentdatetime-bechmark_date);
       if isempty(disease_index)~=1
           if isempty(strfind(filteredData{index1,8},'男'))~=1%如果性别是男
               male_number(passdays,disease_index)=male_number(passdays,disease_index)+1;

               currentage=filteredData{index1,9};%患者年龄
               age{passdays,disease_index}=[age{passdays,disease_index} currentage];
           else
                female_number(passdays,disease_index)=female_number(passdays,disease_index)+1;
                currentage=filteredData{index1,9};%患者年龄
               age{passdays,disease_index}=[age{passdays,disease_index} currentage];
           end
           % diseases_number(passdays,disease_index)=diseases_number(passdays,disease_index)+1;
       end
    end
    
    
    
end


%读取原始疾病诊断记录
original_data=table2cell(readtable('D:\FCM202601\呼吸科数据2021-2025.09.csv'));
copy_original_data=original_data;

% 筛选第7列为'主要诊断'的数据
targetCity = '主要诊断';
columnIndex = 7;

% 方法1：使用 strcmp（精确匹配字符串）
isBeijing = strcmp(copy_original_data(:, columnIndex), targetCity);
filteredData = copy_original_data(isBeijing, :);

%替换疾病名称
deleted_row_number=[];
for index1=1:size(filteredData,1)
    current_disease_name=filteredData{index1,6};
    %查找这种疾病名称的位置
    if isempty(strfind(address,'上海'))~=1
        for category_index=1:numel(values)
            if category_index~=1 
                isInCell = ismember(current_disease_name, values{category_index});
                if isInCell==1
                    %替换成找到的疾病
                    filteredData{index1,6}=keys{category_index};
                    break;
                end
            end
        end
    else
         %不包含上海，则删除本行（记录行号，后边一次删除）
        deleted_row_number=[deleted_row_number index1];
    end
end

%删除不要的行
filteredData(deleted_row_number, :) = [];

%替换完疾病之后，将filteredData按照日期进行统计
dateSeries1 = datetime(2016,1,1):datetime(2025,12,31);
for index1=1:size(filteredData,1)
    inhospitaldate=filteredData{index1,11};%入院日期
    %把入院日期变成date类型
    spaceposition=strfind(inhospitaldate,' ');%找到空格
    specificdate=inhospitaldate(1:spaceposition-1);
    Datestring = strrep(specificdate, '/','-');%分割年月日
    currentdatetime=datetime(Datestring);
    
    currentyear=year(currentdatetime);
    if currentyear>=2016 && currentyear<=2025%仅仅计算2016-2025的日期
       %找到修改过的疾病为第几种疾病(keys中的元素序号)
       disease_index=find(strcmp(keys,filteredData{index1,6})==1);
       passdays=days(currentdatetime-bechmark_date);
       if isempty(disease_index)~=1
           if isempty(strfind(filteredData{index1,8},'男'))~=1%如果性别是男
               male_number(passdays,disease_index)=male_number(passdays,disease_index)+1;

               currentage=filteredData{index1,9};%患者年龄
               age{passdays,disease_index}=[age{passdays,disease_index} currentage];
           else
                female_number(passdays,disease_index)=female_number(passdays,disease_index)+1;
                currentage=filteredData{index1,9};%患者年龄
               age{passdays,disease_index}=[age{passdays,disease_index} currentage];
           end
       end
    end
    
    
    
end
%三个变量的第一列全部删除
age(:,1)=[];
male_number(:,1)=[];
female_number(:,1)=[];
save('age.mat','age');
save('male_number.mat','male_number')
save('female_number.mat','female_number')

%继续统计年龄和性别
cum_days=[0,366,365,365,365,366,365,365,365,366];%16-24年
each_year_days=cumsum(cum_days);%累加每年的天数
%统计每种病每一年的年框以及不分年每种病的情况
all_info={};
for index=2:numel(each_year_days)
    start_days=each_year_days(index-1)+1;
    end_days=each_year_days(index);
    part_age=age(start_days:end_days,:);
    part_male=male_number(start_days:end_days,:);
    part_female=female_number(start_days:end_days,:);
    part_male_sum=sum(part_male);
    part_female_sum=sum(part_female);
    %处理年龄
   
    mean_age_for_disease=[];
    std_age_for_disease=[];
    for col_index=1:size(part_age,2)
        temp_age_sum=[];
        for row_index=1:size(part_age,1)
            temp_age_sum=[temp_age_sum part_age{row_index,col_index}];
        end
        mean_age_for_disease=[mean_age_for_disease mean(temp_age_sum)];
        std_age_for_disease=[std_age_for_disease std(temp_age_sum)];

    end
    temp_info={};%存储每一年的所有疾病的信息
      for item_index=1:numel(part_male_sum)
          temp_info=[temp_info [num2str(part_male_sum(item_index)) ',' num2str(part_female_sum(item_index)) '/' num2str(mean_age_for_disease(item_index)) '@' num2str(std_age_for_disease(item_index))]];  
      end
        
        all_info=[all_info; temp_info];
    
end
%最后一行不分年份
    male_sum=sum(male_number);
    female_sum=sum(female_number);
   
    mean_age_for_disease=[];
    std_age_for_disease=[];
    for col_index=1:size(age,2)
         temp_age_sum=[];
        for row_index=1:size(age,1)
            temp_age_sum=[temp_age_sum age{row_index,col_index}];
        end
        mean_age_for_disease=[mean_age_for_disease mean(temp_age_sum)];
        std_age_for_disease=[std_age_for_disease std(temp_age_sum)];

    end
      temp_info={};%存储每一年的所有疾病的信息
      for item_index=1:numel(male_sum)
          temp_info=[temp_info [num2str(male_sum(item_index)) ',' num2str(female_sum(item_index)) '/' num2str(mean_age_for_disease(item_index)) '@' num2str(std_age_for_disease(item_index))]];  
      end
       all_info=[all_info; temp_info];
       xlswrite('人口学信息.xlsx',all_info);