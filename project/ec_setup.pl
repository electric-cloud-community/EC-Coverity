my %runCoverity = (
    label       => "Coverity - Code Analysis",
    procedure   => "runCoverity",
    description => "Execute static analisis to C/C++, Java and C# source",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/Coverity - Code Analysis");  
$batch->deleteProperty("/server/ec_customEditors/pickerStep/coverity");

@::createStepPickerSteps = (\%runCoverity);
