%先出后入
clc
clear all
root_dir='D:\FCM202601\model';
cd(root_dir);
subdirs = struct2cell(dir(root_dir));
len=size(subdirs,2);
for index0011=1:len
if isempty(strfind(subdirs{1,index0011},'all_model.txt'))~=1

save_path_dir='D:\FCM202601\degree';
model_name=subdirs{1,index0011};
matrix=load(model_name);%导入数据
result=zeros(29,29);%第二个模型改成10,统计所有的两两因素之间的度
[rows,cols]=find(matrix~=0);
    for index=1:numel(rows)
       result(rows(index),cols(index))=1;
    end
    outdegree=sum(result,2);
    indegree=sum(result,1);
    indegree=indegree';
    save_result=[outdegree indegree];
     save_file_name=[save_path_dir,'\',strrep(model_name,'.txt',''),'.xlsx'];
     save_result=num2cell(save_result);
     xlswrite(save_file_name,save_result);
end
end