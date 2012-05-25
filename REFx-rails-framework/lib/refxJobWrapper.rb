#
#  jobWrapper.rb
#  refxlooptests
#
#  Created by Pim Snel on 04-10-11.
#  Copyright 2011 Lingewoud B.V. All rights reserved.
#


#!/usr/bin/env ruby
require 'optparse'
require 'fileutils'
require 'base64'

class RefxJobWrapper
    
    def runJob(pJob)
        
        p "start running job"
        pJob.attempt = pJob.attempt.to_i + 1
        
        ## SAVE JOB: attempt + 1
        pJob.save
        
        if pJob.attempt > pJob.max_attempt
            pJob.status = 66
            else
            #logger.info(Time.now.to_s+': start processing job '+ pJob.id.to_s)
            cmdbody = YAML::load(pJob.body)
            
            #We always add the jobId to the init arguments on the first position
            initArgString = "'"+pJob.id.to_s+"'"
            
            #IF THE PLUGIN NEEDS MORE ARGUMENTS
            initArgString2= createArgString(cmdbody['init_args'])
            
            initArgString = initArgString + ',' + initArgString2 if not initArgString.nil?
            
            methodArgString= createArgString(cmdbody['method_args'])
            
            ##### CMDBODY DEBUG
            
            #logger.info 'engine: '+pJob.engine
            #logger.info 'method: '+cmdbody['method']
            #logger.info 'init_args: '+ initArgString
            #logger.info 'method_args: '+ methodArgString
            
            # CREATE ENGINE OBJECT and make sure the engine object is nil
            @engineObject=nil
            evalcmd1=pJob.engine+'.new('+initArgString+')'
            @engineObject = eval(evalcmd1)
            
            if @engineObject
                logStartNewJob
                
                evalcommand='@returnVal = @engineObject.'+cmdbody['method']+'('+methodArgString+')'
                
                @startTime = 'REFx JOB STARTED :  '+Time.now.to_s
                eval(evalcommand)
                @endTime = 'REFx JOB FINISHED : '+Time.now.to_s
                logJobSummery
                
                pJob.status = 10
                pJob.returnbody = @returnVal
                else
                errorMsg = "engine "+pJob.engine+" does not exist"
                pJob.returnbody = errorMsg
                pJob.status = 20
            end
        end
        ## SAVE JOB: in loop
        pJob.save
    end
    
    def selectJobById(jobId)
        pJob = Job.find(jobId)
        runJob(pJob)
    end
   
    def selectJob()
        # select job ONE to process starting with highest priority
        processJobs = Job.find(:all,:conditions => ["status > 0 AND status < 10"], :order => "jobs.priority DESC", :limit => 1)
        
        # walk through jobs
        processJobs.each do |pJob|
        end
    end         
    
    def logStartNewJob
        open('log/pas3.log', 'a') { |f|
            f.puts "\n"
            f.puts "------------ STARTING A NEW REFx JOB -------------\n"
            f.puts "\n"
        }
    end
    def logJobSummery
        open('log/pas3.log', 'a') { |f|
            f.puts "\n"
            f.puts "--------------------------------------------------\n"
            f.puts @startTime +"\n"
            f.puts @endTime +"\n"
            f.puts "--------------------------------------------------\n"
            f.puts "\n"
        }
    end


    def createArgString(argArr)
        if  not argArr.nil? and not argArr.empty?
            @initArgArr = Array.new
            argArr.each do |iArg|
                if iArg['type'] == "string"
                    if(iArg['value'].class == Array)
                        iArg['value'] = '[' + iArg['value'].to_s + ']'
                        elsif(iArg['value'].nil?)
                        iArg['value'] = ""
                        else
                        iArg['value'] = iArg['value'].delete("\n")
                    end
                    
                    iArg['value']  = Base64.encode64(iArg['value'])
                    
                    @initArgArr<< "'"+ iArg['value'] +"'"
                    else
                    @initArgArr<< iArg['value']
                end
            end
            newString = @initArgArr.join(',')
            return newString
        end
        
        return ''
    end
    
end



# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
    opts.banner = "Usage: refxJobWrapper.rb -j <JOBID>"
        
    options[:environment] = 'development'
    opts.on( '-l', '--environment environment', 'rails environment' ) do|environment|
        options[:environment] = environment
    end
    
    options[:jobid] = nil
    opts.on( '-j', '--jobid jobid', 'jobid' ) do|jobid|
        options[:jobid] = jobid
    end
    
    # This displays the help screen, all programs are
    # assumed to have this option.
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

#puts "Being verbose" if options[:verbose]
#puts "Logging to file #{options[:logfile]}" if options[:logfile]
p options[:jobid]

if options[:jobid] != 0
    
    refxjob = RefxJobWrapper.new
    refxjob.selectJobById(options[:jobid])
end

exit 0
