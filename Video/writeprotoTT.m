function [st] = writeprotoTT(p,FILENAME,PARAMETER_KIND)

% Converted from MakeHMMPrototype, written by David Dean, 2004
% http://www.davidbdean.com/2006/11/16/code-create-prototype-htk-hmm/

if strcmp(FILENAME,'')
  sprintf('Written by David Dean, 2004\n\n')
  sprintf('Generates a forward only, diagonal covariance HMM prototype\n\n')
  sprintf('usage:\n')
  sprintf('   writeproto4 name parameterkind vectorsize numberstates mixturesperstate \\\n')
  sprintf('                [ streamcount vecsize1 ... vecsizeN [ weight1 ... weightN ] ]\n\n')
  sprintf('   name             : name of hmm (eg. prototype)\n')
  sprintf('   parameterkind    : parameter kind (eg. MFCC_0_D_A)\n')
  sprintf('   vectorsize       : size of feature vector\n')
  sprintf('   numberstates     : total number of states\n')
  sprintf('   mixturesperstate : number of mixtures per state\n')
  sprintf('   streamcount ...  : multiple-stream support\n')
  sprintf('      vecsizeN      : size of each stream (must total to vectorsize)\n')
  sprintf('      weightN       : weight of each stream on final score (defaults to 1)\n')
  st=0;
else
    
  MIXTURE_WEIGHT = 1.0 / p.hmm_mixes;
  INITIAL_MEAN = 0.0;
  INITIAL_VARIANCE = 1.0;   
  
  ofile=fopen(FILENAME,'w');
  
  % output header
  fprintf(ofile,'~o <VecSize> %d <%s>\n',p.hmm_features,PARAMETER_KIND);
  if (length(p.hmm_streams) > 1)
    fprintf(ofile,'   <StreamInfo> %d',length(p.hmm_streams));
    for stream = 1:length(p.hmm_streams)
      fprintf(ofile,' %d',p.hmm_streams(stream));
    end
    fprintf(ofile,'\n');
  end
  fprintf(ofile,'<BeginHMM>\n');
  fprintf(ofile,' <NumStates> %d\n',p.hmm_states+2);
  
  % output each emitting state (ie. not the first or last)
  for state=2:(p.hmm_states+1)
    
    fprintf(ofile,' <State> %d\n',state);
    
    fprintf(ofile,'  <NumMixes>'); 
    for stream=1:length(p.hmm_streams)
      fprintf(ofile,' %d',p.hmm_mixes);
    end
    fprintf(ofile,'\n');
     
    fprintf(ofile,'  <SWeights> %d',length(p.hmm_streams));
    for stream=1:length(p.hmm_streams)
      fprintf(ofile,' %g',p.hmm_weights(stream));
    end
    fprintf(ofile,'\n');

    for stream=1:length(p.hmm_streams)

      if (length(p.hmm_streams) > 1)
    	fprintf(ofile,'  <Stream> %d\n',stream);
      end

      % output each mixture for each state
      for mixture=1:p.hmm_mixes
        fprintf(ofile,'   <Mixture> %d %g\n',mixture,MIXTURE_WEIGHT);
	
	    % output mean values for each mixture
        fprintf(ofile,'    <Mean> %d\n',p.hmm_streams(stream));
        fprintf(ofile,'    ');
        for feature=1:p.hmm_streams(stream);
    	    fprintf(ofile,' %f',INITIAL_MEAN);
        end
        fprintf(ofile,'\n');
	
        % output diagonal covariance values for each mixture
        fprintf(ofile,'    <Variance> %d\n',p.hmm_streams(stream));
        fprintf(ofile,'    ');
    	for feature=1:p.hmm_streams(stream)
    	   fprintf(ofile,' %f',INITIAL_VARIANCE);
        end
        fprintf(ofile,'\n');
      end
    end
  end
  
  % transition matrix
  fprintf(ofile,' <TransP> %d\n',p.hmm_states+2);
  for statefrom=1:p.hmm_states+2
      fprintf(ofile,' ');
      for stateto=1:p.hmm_states+2
    	  if (statefrom==1 && stateto==2)
             fprintf(ofile,' %f',1.0);
          else
              if (statefrom>1 && statefrom<(p.hmm_states+2) && (stateto==statefrom || stateto==(statefrom+1)))
                 fprintf(ofile,' %f',0.5);
              else 
                 fprintf(ofile,' %f',0.0);
              end
          end
      end
      fprintf(ofile,'\n');
  end
  
  % output footer
  fprintf(ofile,'<EndHMM>\n');

  fclose(ofile);
  st=1;
end
end
