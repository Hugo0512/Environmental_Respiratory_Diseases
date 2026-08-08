clc
clear all
warning off
variablenumber=17;%%%%%%%%%%%%%%%%%%%%%%%16���������������ؼ�һ���������������������ĳһ�ּ�����
totaldata={};
sigma=5;
order=1;%����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ʱ�޸�
%������ȱֵ
%֮���ѵ�����ݺ���֤����
indepenedent_variable_number=16;%%%%%%%%%%%%16����������������
dependent_variable_number=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ʱ�޸�

%parpool('local', 10);
%parpool(10);
raw=[];
climate=load('weather.txt');
air=load('air.txt');
diseases=load('disease.txt');
raw=[air climate diseases];
           raw=fillmissing(raw, 'linear', 2);     
               [row, col] = find(isnan(raw))
               
                for colindex=1:size(raw,2)
                    raw(:,colindex)=(raw(:,colindex)-min(raw(:,colindex)))/(max(raw(:,colindex))-min(raw(:,colindex)));
                end
                %��ѵ������֤���ݣ�ѵ�����Ҳ���
                
                
      for dependent_index=17:29  %13�ּ����ֿ���ģ 
          
          
                traindata=raw(1:round(size(raw,1)*0.8),[1:indepenedent_variable_number,dependent_index]);
                testdata=raw(round(size(raw,1)*0.8)+1:end,[1:indepenedent_variable_number,dependent_index]);
                
                lastresults=[];
                lastfitness=[];
                
                parfor index777=1:10
    index777
    
% for index000=9%6%:11
   
    historybestindividual=[];
    historybestfitness=Inf;
sparseratio=0.4;    
N=100;%��Ⱥ��ģ
pop=[];%��Ⱥ
for index=1:N
    for index1=1:variablenumber
        for index2=1:variablenumber
            if rand()<sparseratio
                pop(index,variablenumber*(index1-1)+index2)=0;
            else
                pop(index,variablenumber*(index1-1)+index2)=rand()*2-1;
            end
           
%            pop(index,variablenumber*(index1-1)+index2)=rand()*2-1;
        end
    end
     pop(index,(indepenedent_variable_number*(indepenedent_variable_number+dependent_variable_number)+1):(indepenedent_variable_number*(indepenedent_variable_number+dependent_variable_number)+indepenedent_variable_number))=0;%�����������������ص�Ӱ�����
    
    
end

F=0.8;%��������
maxiterations=500;%��������
CR=0.2;
for index1=1:maxiterations
    index1
    for index2=1:N
       middlearray=pop(index2,:);
       selected=randperm(N);
        mutationarray=pop(selected(3),:)+F*(pop(selected(1),:)-pop(selected(2),:));
        crossnum=0;
        for index3=1:variablenumber^2
            label=rand();
            if(label<CR)
                middlearray(index3)=mutationarray(index3);
                croassnum=crossnum+1;
            end
        end
           if crossnum==0
%                exchangepoint=randi(1,1,[1 variablenumber^2]);
                 exchangepoint=randi([1 variablenumber^2],[1 1]);
               middlearray(exchangepoint)=mutationarray(exchangepoint);          
           end
%         fitness1=(middlearray(1)-7)*(middlearray(1)-7)+(middlearray(2)+6)*(middlearray(2)+6)+(middlearray(3)-9)*(middlearray(3)-9);
%         fitness2=(pop(index2,1)-7)*(pop(index2,1)-7)+(pop(index2,2)+6)*(pop(index2,2)+6)+(pop(index2,3)-9)*(pop(index2,3)-9);
%         if fitness1<fitness2
%             pop(index2,:)=middlearray;
%         end
   for index9=1:numel(middlearray)
           if middlearray(index9)>1
               middlearray(index9)=1;
           end
            if middlearray(index9)<-1
               middlearray(index9)=-1;
            end   
   end
       middlearray((indepenedent_variable_number*(indepenedent_variable_number+dependent_variable_number)+1):(indepenedent_variable_number*(indepenedent_variable_number+dependent_variable_number)+indepenedent_variable_number))=0;%�����������������ص�Ӱ�����
    %���ٷ�0��ֵ�ĸ���
       nonzero=find(middlearray~=0);
       nonzeronumber=numel(nonzero);
       if nonzeronumber>variablenumber^2*(1-sparseratio)-variablenumber
           needzero=round(variablenumber^2*(1-sparseratio)-variablenumber);
%            position=randi(1,needzero,[1,variablenumber^2]);
           position=randi([1,variablenumber^2],[1 needzero]);
              %ѡ�񼸸����0
              middlearray(position)=0;
       end
    %���һ������Ϊ0
    
    %���һ������Ϊ0
%     for index=6:variablenumber
%      middlearray((index-1)*variablenumber+1:(index-1)*variablenumber+5)=0;
%     end
%̰��ѡ��middlearray��pop(index2,:)��
%�����������������Ӧ��
%���ȼ���ÿ�����е���ֵ,Ⱦɫ��ָ��ɾ���
middlearraymatrix=[];
        for index4=1:variablenumber
            for index5=1:variablenumber
                middlearraymatrix(index4,index5)=middlearray((index4-1)+index5);
            end
        end
%����ÿ�����е�ֵ
computationresult={};

  tempsequence=traindata;%%%%%%%%%%%%%%%%%%%%%%%%%%%
  sequence=[];
  sequence(1:order,:)=tempsequence(1:order,:);%�洢ģ�Ͳ���������ֵ
  for index7=order+1:size(tempsequence,1)
    for index6=1:variablenumber
             temp=0;
            for index789=1:order
                temp=temp+(sequence(index7-index789,:).^index789)*middlearraymatrix(:,index6);
                %sequence(index7,index6)=sequence(index7-1,:)*middlearraymatrix(:,index6);
            end
         sequence(index7,index6)=1/(1+exp(-sigma*temp));
        end
  end
  computationresult=sequence;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%�������
fitness1=0;

     sequence=computationresult;
     tempsequence=traindata;
        fitness1=fitness1+sum(sum((tempsequence(2:end,:)-sequence(2:end,:)).^2))/(variablenumber*(size(tempsequence,1)-1));

%���ȼ���ÿ�����е���ֵ,Ⱦɫ��ָ��ɾ���
middlearraymatrix=[];
anothervector=pop(index2,:);
        for index4=1:variablenumber
            for index5=1:variablenumber
                middlearraymatrix(index4,index5)=anothervector((index4-1)+index5);
            end
        end
%����ÿ�����е�ֵ
computationresult1={};

  tempsequence=traindata;
    sequence1=[];
  sequence1(1:order,:)=tempsequence(1:order,:);%�洢ģ�Ͳ���������ֵ
  for index7=order+1:size(tempsequence,1)
    for index6=1:variablenumber
             temp=0;
            for index789=1:order
                temp=temp+(sequence1(index7-index789,:).^index789)*middlearraymatrix(:,index6);
                %sequence(index7,index6)=sequence(index7-1,:)*middlearraymatrix(:,index6);
            end
         sequence1(index7,index6)=1/(1+exp(-sigma*temp));
        end
  end
    computationresult1=sequence1;

%�������
fitness2=0;

    sequence1=computationresult1;
    tempsequence=traindata;
    fitness2=fitness2+sum(sum((tempsequence(2:end,:)-sequence1(2:end,:)).^2))/(variablenumber*(size(tempsequence,1)-1));



    if fitness1<fitness2
            pop(index2,:)=middlearray;
    end 
    if min(fitness1,fitness2)<historybestfitness
        historybestfitness=min(fitness1,fitness2);
        if fitness1<fitness2
          historybestindividual=middlearray;
        else
            historybestindividual=pop(index2,:);
        end
    end
    %����ȡֵ��Χ
 
       end
end
%�ҳ���õ�һ��
result=[];
fitness=zeros(1,N);
for index=1:N
    %�ҳ�ÿһ�����壬������Ӧ��
    tempvector=pop(index,:);
     for index4=1:variablenumber
            for index5=1:variablenumber
                middlearraymatrix(index4,index5)=tempvector((index4-1)+index5);
            end
     end
     
          tempsequence=testdata;
          sequence1=[];
         sequence1(1:order,:)=tempsequence(1:order,:);%�洢ģ�Ͳ���������ֵ
         for index7=order+1:size(tempsequence,1)
            for index6=1:variablenumber
                 temp=0;
                for index789=1:order
                    temp=temp+(sequence1(index7-index789,:).^index789)*middlearraymatrix(:,index6);
                    %sequence(index7,index6)=sequence(index7-1,:)*middlearraymatrix(:,index6);
                end
                   sequence1(index7,index6)=1/(1+exp(-sigma*temp));
            end
        end
       computationresult=sequence1;
 
   
         tempsequence=testdata;
         sequence1=computationresult;
         fitness(index)=fitness(index)+sum(sum((tempsequence-sequence1).^2))/(variablenumber*(size(tempsequence,1)-1));
     
end
        if min(fitness)<historybestfitness
            number=find(fitness==min(fitness));
            historybestindividual=pop(number,:);
            historybestfitness=min(fitness);
        end
% end%��index000ƥ��
%lastresult(index777,:)=historybestindividual;
%lastfitness(index777)=historybestfitness;
lastresults(index777,:)=historybestindividual;
lastfitness(index777)= historybestfitness;
%lastresults=[lastresults;historybestindividual];
%lastfitness=[lastfitness historybestfitness];

end%��Ӧindex777
         save(['lastresult_',num2str(order),'_',num2str(dependent_index),'.mat'],'lastresults');
         save(['lastfitness_',num2str(order),'_',num2str(dependent_index),'.mat'],'lastfitness');
                
      end         
          








