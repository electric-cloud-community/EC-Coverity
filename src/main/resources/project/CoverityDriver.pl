	# -------------------------------------------------------------------------
	# Package
	#    coverityDriver.pl
	#
	# Dependencies
	#    None
	#
	# Purpose
	#    Template for Single Command-line Plug-ins
	#
	# Template Version
	#    1.0
	#
	# Date
	#    07/20/2011
	#
	# Engineer
	#    Carlos Rojas
	#
	# Copyright (c) 2011 Electric Cloud, Inc.
	# All rights reserved
	# -------------------------------------------------------------------------

	# -------------------------------------------------------------------------
	# Includes
	# -------------------------------------------------------------------------
	use ElectricCommander;
	use warnings;
	use strict;
	use Cwd;
	$|=1;

    # -------------------------------------------------------------------------
	# Constants
	# -------------------------------------------------------------------------
	use constant {
	   BUILDEXEC => "cov-build",
	};

	########################################################################
	# trim - deletes blank spaces before and after the entered value in
	# the argument
	#
	# Arguments:
	#   -untrimmedString: string that will be trimmed
	#
	# Returns:
	#   trimmed string
	#
	########################################################################
	sub trim{
        my ($untrimmedString) = @_;
        my $string = $untrimmedString;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
	}

	# -------------------------------------------------------------------------
	# Variables
	# -------------------------------------------------------------------------
	$::gCoverityPath         = trim(q($[Coverity_path]));
	$::gDirectory            = trim(q($[Intermediate_directory]));
    $::gLanguage             = trim("$[Language]");
    $::gDebug                = trim("$[Debug]");
    $::gVerboseLevel         = trim("$[Verbosity_level]");
    $::gBuildCommand         = trim(q($[Build_command]));
	$::gConfigFile           = trim(q($[Config_file]));
	$::gExtraBuildCommands   = trim("$[ExtraBuildCommands]");
    $::gExtraAnalyzeCommands = trim("$[ExtraAnalyzeCommands]");
    $::gWorkingDir           = trim(q($[workingdir]));
	$::gAssemblyFiles        = trim(q($[AssemblyFiles]));

	#more global variables to be added here

	# -------------------------------------------------------------------------
	# Main functions
	# -------------------------------------------------------------------------


	########################################################################
	# main - contains the whole process to be done by the plugin, it builds
	#        the command line, sets the properties and the working directory
	#
	# Arguments:
	#   none
	#
	# Returns:
	#   none
	#
	########################################################################
	sub main {

        # create args array
        my @covBuildArgs = ();
        my @covAnalyzeArgs = ();

        #properties' map
        my %props;

        my $binDirectory = "";

        if($::gCoverityPath && $::gCoverityPath ne ""){
            $binDirectory = $::gCoverityPath;
        }
        if($binDirectory ne ""){
            push(@covBuildArgs, '"' . $binDirectory . "/" . BUILDEXEC . '"');
        }else{
            push(@covBuildArgs, BUILDEXEC);
        }

        my $AnalyzeExecutable = "";

        #depending on the language we use, the analyzer executable will change
        if($::gLanguage && $::gLanguage ne "")
        {
            if($::gLanguage eq "java"){
                $AnalyzeExecutable = "cov-analyze-java";
            }elsif($::gLanguage eq "csharp"){
                $AnalyzeExecutable = "cov-analyze-cs";
            }else{
                $AnalyzeExecutable = "cov-analyze";
            }
            if($binDirectory ne ""){
                push(@covAnalyzeArgs, '"' . $binDirectory . "/" . $AnalyzeExecutable . '"');
            }else{
                push(@covAnalyzeArgs, $AnalyzeExecutable);
            }
        }

        #change default config file
        if($::gConfigFile && $::gConfigFile ne ""){
            push(@covBuildArgs,   "--config " . '"' . $::gConfigFile . '"');
            push(@covAnalyzeArgs, "--config " . '"' . $::gConfigFile . '"');
        }

        #assembly files for cov-Analyze-cs
        if($::gLanguage && $::gLanguage eq "csharp"){
           if($::gAssemblyFiles && $::gAssemblyFiles ne ""){
                push(@covAnalyzeArgs, $::gAssemblyFiles);
           }
        }

        #enable debug mode
        if($::gDebug && $::gDebug ne ""){
            push(@covBuildArgs , "--debug");
            if($::gLanguage && $::gLanguage ne "csharp"){
                push(@covAnalyzeArgs , "--debug");
            }
        }

        #intermediate directory
        if($::gDirectory && $::gDirectory ne ""){
            push(@covBuildArgs,   "--dir " . '"' . $::gDirectory . '"');
            push(@covAnalyzeArgs, "--dir " . '"' . $::gDirectory . '"');
        }

        #verbose level (from 1 to 4) cov-Analyze-cs doesn't support this option
        if($::gVerboseLevel && $::gVerboseLevel ne "" && $::gLanguage && $::gLanguage ne "csharp"){
            push(@covAnalyzeArgs, "--verbose $::gVerboseLevel");
        }

        #the command user usually uses for build his/her project
        if($::gBuildCommand && $::gBuildCommand ne ""){
            push(@covBuildArgs, $::gBuildCommand);
        }

        #extra build options
        if($::gExtraBuildCommands && $::gExtraBuildCommands ne ""){
            push(@covBuildArgs, $::gExtraBuildCommands);
        }

        #extra analisys options
        if($::gExtraAnalyzeCommands && $::gExtraAnalyzeCommands ne "")
        {
            push(@covAnalyzeArgs, $::gExtraAnalyzeCommands);
        }

        #generate the command(s) to execute in console

        #we won't generate a build command line if the user did not specify the build command
        if($::gBuildCommand && $::gBuildCommand ne ""){
            $props{"buildCommandLine"} = createCommandLine(\@covBuildArgs);
        }else
        {
            $props{"buildCommandLine"} = "";
        }
        $props{"AnalyzeCommandLine"} = createCommandLine(\@covAnalyzeArgs);
        if($::gWorkingDir && $::gWorkingDir ne ""){
            $props{"workingdir"} = $::gWorkingDir;
        }

        setProperties(\%props);

	}

	########################################################################
	# createCommandLine - creates the command line for the invocation
	# of the program to be executed.
	#
	# Arguments:
	#   -arr: array containing the command name and the arguments entered by
	#         the user in the UI
	#
	# Returns:
	#   -the command line to be executed by the plugin
	#
	########################################################################
	sub createCommandLine {

		my ($arr) = @_;

		my $commandName = @$arr[0];

		my $command = $commandName;

		shift(@$arr);

		foreach my $elem (@$arr) {
			$command .= " $elem";
		}

		return $command;

	}

	########################################################################
	# setProperties - set a group of properties into the Electric Commander
	#
	# Arguments:
	#   -propHash: hash containing the ID and the value of the properties
	#              to be written into the Electric Commander
	#
	# Returns:
	#   -nothing
	#
	########################################################################
	sub setProperties{

		my ($propHash) = @_;

		# get an EC object
		my $ec = new ElectricCommander();
		$ec->abortOnError(0);
        my $pluginKey = 'EC-Coverity';
        my $xpath = $ec->getPlugin($pluginKey);
        my $pluginName = $xpath->findvalue('//pluginVersion')->value;
        print "Using plugin $pluginKey version $pluginName\n";

		foreach my $key (keys % $propHash) {
			my $val = $propHash->{$key};
			$ec->setProperty("/myCall/$key", $val);
		}

	}

	main();
