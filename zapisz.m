function zapisz(name) 
s=hgexport('readstyle','moje');

 fnam=[name,'.png']; % your file name
 s.Format = 'png'; %I needed this to make it work but maybe you wont.
 hgexport(gcf,fnam,s);
end