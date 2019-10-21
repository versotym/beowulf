function [prior,inpaper]=compounds_model

%<plechac>
% Modification of the script provided by authors
% Corresponds to the documents in calgary_proce_x.txt
% Beowulf always treated as two separate documents
%</plechac>


%Clustering analysis of OE poems based on compound words
load('compounds_data.mat','cf','cvec', 'names');
%######INPUTS
%cf: vector of frequencies of non-hapax compounds. Note that
%'middangeard','heofonrice','heofoncyning', and 'wuldorcyning' have their
%frequency set to 0 here as per the paper.
%
%cvec: Number of compounds in each poem, counting Beowulf 1-2300 and
%2301-end as separate
%
%cvecBEO: Same as above but counting Beowulf as one poem

prior=zeros(length(cvec));
for trial=1:10000
    disp(trial);
    rng shuffle
pair=zeros(length(cvec));
matter=cvec./sum(cvec); %Probability distribution that a random iteration of a compound word ends up in a given poem

for Compound=1:length(cf) %Loop over all OE compounds
    texts=[]; 
    for Instance=1:cf(Compound)
        samp=gdist(matter',1,1);
        texts=[texts,samp]; %Assign iteration of compound to a text based on 'matter' probability distribution
    end   
    texts=sort(unique(texts)); %We don't count frequencies, just appearances, so 'unique' removes multiple iterations of a compound
    for lbj=1:length(texts)
        for jfk=1:length(texts)
            if texts(lbj)~=texts(jfk)
                pair(texts(lbj),texts(jfk))=pair(texts(lbj),texts(jfk))+1; %Match all poems with overlapping compounds
            end
        end
    end
end

prior=prior+pair;

end %of trials

%prior=triu(prior)/10000;
prior = prior/10000;
csvwrite('compounds_prior.csv',prior);
T = cell2table(names(2:end), 'VariableNames', names(1))
%writetable(T, 'compounds_prior_names.csv');

function T = gdist(pvec,N,M)
Pnorm=[0 pvec]/sum(pvec); %PP: this is simply division by 1 (??)
Pcums=cumsum(Pnorm); 
N=round(N); %PP: this == round(1) (?)
M=round(M); %PP: this == round(1) (?)
R=rand(1,N*M); 
V=1:length(pvec); 
[~,inds] = histc(R,Pcums);  
T = V(inds); %PP: as V contains rising numbers this doesn't do anything else than T = inds (?)
T=reshape(T,N,M); %PP: again: reshaping 1x1 matrix doesn't do anything (?)
end %of gdist
end %of OECompCcomlust