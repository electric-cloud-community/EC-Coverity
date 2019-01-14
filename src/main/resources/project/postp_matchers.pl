@::gMatchers = (
  {
    id =>        "cov-license",
    pattern =>          q{License has expired},
    action =>           q{&addSimpleError("cov-license", "License has expired");updateSummary();},
  },
  #total time
  {
    id =>        "cov-time",
    pattern =>          q{Total time: (.*)},
    action =>           q{&addSimpleError("cov-time", "Total time: $1");updateSummary();},
  },
  #warnings
  {
    id =>        "cov-warnings",
    pattern =>          q{(\d+) warnings},
    action =>           q{&addSimpleError("cov-warnings", "Total warnings: $1");updateSummary();},
  },
  #errors
  {
    id =>        "cov-errors",
    pattern =>          q{Total errors found: (\d+)},
    action =>           q{&addSimpleError("cov-errors", "Total errors found: $1");updateSummary();},
  },
  #Analyzed files
  {
    id =>         "cov-analyzed",
    pattern =>          q{Files analyzed(.*)},
    action =>           q{&addSimpleError("cov-analyzed", "Files analyzed $1");updateSummary();},
  },
  #missing files or source code
  {
    id =>         "cov-missing-sources",
    pattern =>          q{(\d+) out of (\d+) (.*)code\.},
    action =>           q{&addSimpleError("cov-missing-sources", "$1 out of $2 $3 code");updateSummary();},
  },
  #new defects found
  {
    id =>         "cov-defects-found",
    pattern =>          q{New defects found(.*)},
    action =>           q{&addSimpleError("cov-defects-found", "New defects found $1");updateSummary();},
  },
  #config file not found
  {
    id =>         "cov-not-found-config-file",
    pattern =>          q{\[ERROR\] Could not find COVERITY configuration file (.*) specified},
    action =>           q{&addSimpleError("cov-not-found-config-file", "Could not find Coverity config file: $1");updateSummary();},
  },
  #invalida config file
  {
    id =>         "cov-invalid-conf-file",
    pattern =>          q{\[COVERITY ERROR\] (.*): warning: xml document not valid},
    action =>           q{&addSimpleError("cov-invalid-conf-file", "Invalid config file: $1");updateSummary();},
  },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty ($name, $customError);
    }
}

sub incValueWithString($;$$) {
    my ($name, $patternString, $increment) = @_;

    $increment = 1 unless defined($increment);

    my $localString = (defined $::gProperties{$name}) ? $::gProperties{$name} :
                                                        $patternString;

    $localString =~ /([^\d]*)(\d+)(.*)/;
    my $leading = $1;
    my $numeric = $2;
    my $trailing = $3;
    
    $numeric += $increment;
    $localString = $leading . $numeric . $trailing;
    diagnostic($localString, "warning", backTo("Tagging "));
    setProperty ($name, $localString);
}

sub updateSummary() {
 
    my $summary = (defined $::gProperties{"cov-license"}) ? $::gProperties{"cov-license"} . "\n" : "";
    
    $summary .= (defined $::gProperties{"cov-errors"}) ? $::gProperties{"cov-errors"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-time"}) ? $::gProperties{"cov-time"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-warnings"}) ? $::gProperties{"cov-warnings"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-analyzed"}) ? $::gProperties{"cov-analyzed"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-missing-sources"}) ? $::gProperties{"cov-missing-sources"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-defects-found"}) ? $::gProperties{"cov-defects-found"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-not-found-config-file"}) ? $::gProperties{"cov-not-found-config-file"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-invalid-conf-file"}) ? $::gProperties{"cov-invalid-conf-file"} . "\n" : "";
    
    setProperty ("summary", $summary);
}