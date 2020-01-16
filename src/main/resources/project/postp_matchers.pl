@::gMatchers = (
  {
    id =>        "cov-license",
    pattern =>          q{License has expired},
    action =>           q{&addSimpleError("cov-license", "License has expired");updateSummary();},
  },
  #total time
  {
    id =>        "cov-time",
    pattern =>          q{Time taken by analysis\s+:\s(.*)|Total time: (.*)|Time taken by analysis\s+:\s(\d+)},
    action =>           q{&addSimpleError("cov-time", "$1");updateSummary();},
  },
  #warnings
  {
    id =>        "cov-warnings",
    pattern =>          q{(\d+) warnings},
    action =>           q{&addSimpleError("cov-warnings", "$1");updateSummary();},
  },
  #errors
  {
    id =>        "cov-errors",
    pattern =>          q{Total errors found: (\d+)},
    action =>           q{&addSimpleError("cov-errors", "$1");updateSummary();},
  },
  #Analyzed files
  {
    id =>         "cov-analyzed",
    pattern =>          q{Files analyzed\s+:\s(\d+)|Files analyzed(.*)},
    action =>           q{&addSimpleError("cov-analyzed", "$1");updateSummary();},
  },
  #missing files or source code
  {
    id =>         "cov-missing-sources",
    pattern =>          q{(\d+) out of (\d+) (.*)code\.},
    action =>           q{&addSimpleError("cov-missing-sources", "$1 out of $2 $3 code");updateSummary();},
  },
  #new defects found
  {
    id =>         "cov-new-defects-found",
    pattern =>          q{New defects found(.*)},
    action =>           q{&addSimpleError("cov-new-defects-found", "$1");updateSummary();},
  },
  #total defects found
  {
    id =>         "cov-total-defects-found",
    pattern =>          q{Defect occurrences found\s+:\s(\d+)},
    action =>           q{&addSimpleError("cov-total-defects-found", "$1");updateSummary();},
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
  #functions analyzed
  {
    id =>         "cov-functions-analyzed",
    pattern =>          q{Functions analyzed\s+:\s(\d+)},
    action =>           q{&addSimpleError("cov-functions-analyzed", "$1");updateSummary();},
  },
  #paths analyzed
  {
    id =>         "cov-paths-analyzed",
    pattern =>          q{Paths analyzed\s+:\s(\d+)},
    action =>           q{&addSimpleError("cov-paths-analyzed", "$1");updateSummary();},
  },
  #total LoC input to cov-analyze
  {
    id =>         "cov-total-loc-input",
    pattern =>          q{Total LoC input to cov-analyze\s+:\s(\d+)},
    action =>           q{&addSimpleError("cov-total-loc-input", "$1");updateSummary();},
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
    $summary .= (defined $::gProperties{"cov-time"}) ? "Total time: " . $::gProperties{"cov-time"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-warnings"}) ? "Total warnings: " . $::gProperties{"cov-warnings"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-analyzed"}) ? "Files analyzed: " . $::gProperties{"cov-analyzed"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-missing-sources"}) ? $::gProperties{"cov-missing-sources"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-new-defects-found"}) ? "New defects found: " . $::gProperties{"cov-new-defects-found"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-total-defects-found"}) ? "Total defects found: " . $::gProperties{"cov-total-defects-found"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-functions-analyzed"}) ? "Total functions analyzed: " . $::gProperties{"cov-functions-analyzed"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-paths-analyzed"}) ? "Total paths analyzed: " . $::gProperties{"cov-paths-analyzed"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-total-loc-input"}) ? "Total line of ocde analyzed: " . $::gProperties{"cov-total-loc-input"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-not-found-config-file"}) ? $::gProperties{"cov-not-found-config-file"} . "\n" : "";
    $summary .= (defined $::gProperties{"cov-invalid-conf-file"}) ? $::gProperties{"cov-invalid-conf-file"} . "\n" : "";
    
    setProperty ("summary", $summary);
}