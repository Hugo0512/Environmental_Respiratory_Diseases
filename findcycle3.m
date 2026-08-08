%本程序查找矩阵中的简单路径存储在一个矩阵中
clc
clear all
root_dir='/home/newdisk/FCM2026';
cd(root_dir);
subdirs = struct2cell(dir(root_dir));
len=size(subdirs,2);
replace_words={'PM2.5','PM10','SO2','CO','NO2','O3','Minimum termperature','Maximum temperature','Temperature','Humidity','Wind speed','Wind level','Atmospheric pressure','Visibility','Precipitation','Cloud cover','Pneumonia','COPD','Asthma','Bronchiectasis',' Pulmonary tuberculosis','Pulmonary NTM disease',' ILD','Pulmonary malignancy','Fungal pulmonary infection','Pulmonary artery embolism','BSI','Pleural effusion','ARDS'};%存储替换的属性名
pathlimit=5;%路径长度限制，不然会组合爆炸

for index0011=1:len
if isempty(strfind(subdirs{1,index0011},'all_model'))~=1%全部模型
temp_replace_words=replace_words;

save_path_dir='/home/newdisk/FCM2026/cycle';
model_name=subdirs{1,index0011};
matrix=load(model_name);%导入数据
result=zeros(29,29);%第二个模型改成10,统计所有的两两因素之间的路径数量
totalsimplepaths={};
    parfor index1=1:29%第二个模型改成10
         cycles={};%存储全部环
        tempdata=matrix(:,index1);%拿出本列
        tempstagetemporalcycles={};%存储当前不是环，但是后续长度增加可能成为环的
        pathlimitindex=1;
        pathlimitindex=pathlimitindex+1;
        for index2=1:numel(tempdata)%找长度为2的简单路径
            if tempdata(index2)~=0 & index2==index1 %存储环
                cycles{numel(cycles)+1}=[index2 index1];
            elseif tempdata(index2)~=0 & index2~=index1 %咱是不是环，但是增加长度可能成为环，所以也要存储
                tempstagetemporalcycles{numel(tempstagetemporalcycles)+1}=[index2 index1];
            end
        end
        flagsimplepath={};%存储中间计算结果
         while numel(tempstagetemporalcycles)~=0%循环找更长的路径
             flagtempstagesimplecycles={};
             pathlimitindex=pathlimitindex+1;
              if pathlimitindex>pathlimit
                break;
             end
            for index3=1:numel(tempstagetemporalcycles)
                tempsimplepathpart1=tempstagetemporalcycles{index3};
                tempstart=tempsimplepathpart1(1);%下一阶段的开始点
                tempdata=matrix(:,tempstart);
                 for index2=1:numel(tempdata)%找长度更长的简单路径
                     %判断此起点是否与后面节点重复
                        tempresult=find(index2==tempsimplepathpart1);
                        if tempdata(index2)~=0 & index2==index1 & isempty(tempresult)~=1 & numel(tempresult)==1%符合环的条件
                            cycles{numel(cycles)+1}=[index2 tempsimplepathpart1];
                        elseif tempdata(index2)~=0 & index2~=index1 & isempty(tempresult)==1%符合简单路径的条件，暂时不是环，但是以后可能是环
                            flagtempstagesimplecycles{numel(flagtempstagesimplecycles)+1}=[index2 tempsimplepathpart1];
                        end
                 end 
            end
            if numel(flagtempstagesimplecycles)~=0
                tempstagetemporalcycles=flagtempstagesimplecycles;
            else
                break;
            end
        end
        totalsimplepaths{index1}=cycles;%此变量存储的是所有的简单路径
        
            %break跳出到此处
            %统计每个起点到终点的数量
            temppaths=totalsimplepaths{index1};
            %将重点是index1的简单路径存xls文件
            maxlength=0;%存储最大路径长度
            for itemindex=1:numel(temppaths)
                specificpath=temppaths{itemindex};
                if numel(specificpath)>maxlength
                    maxlength=numel(specificpath);
                end
            end
            save_result={};
            for itemindex=1:numel(temppaths)
                
                realpath=temppaths{itemindex};
                weights=[];
                for stepindex=1:numel(realpath)-1
                    weights=[weights matrix(realpath(stepindex),realpath(stepindex+1))];
                end
                 %将path中的数字换成名字
                
                realpath_replacename={};
                for realpathindex=1:numel(realpath)
                    realpath_replacename=[realpath_replacename temp_replace_words{realpath(realpathindex)}];
                end
                fillzeropath=[realpath_replacename num2cell(zeros(1,maxlength-numel(temppaths{itemindex}))) prod(weights)];
                
                save_result=[save_result; fillzeropath];
            end
            save_file_name=[save_path_dir,'\',strrep(model_name,'.txt',''),'_',num2str(index1),'.mat'];
            %save_result=num2cell(save_result);
            if size(save_result,1)>0
%             xlswrite(save_file_name,save_result);
            save(save_file_name,'save_result');
            end
            
            for index9=1:29%第二个模型改成10
                for index10=1:numel(temppaths)
                    littlepath=temppaths{index10};
                    if littlepath(1)==index9 & littlepath(end)==index1
                        result(index9,index1)=result(index9,index1)+1;
                    end
                end
            end
    end
    last_save_file_name=[save_path_dir,'/',strrep(model_name,'.txt',''),'_count','.txt'];
    save(last_save_file_name,'result','-ascii')
end
end