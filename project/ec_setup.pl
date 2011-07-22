if ($promoteAction eq 'promote') {

    # The plugin is being promoted, create a property reference in the server's property sheet
    $batch->setProperty('/server/ec_customEditors/pluginStep/coverity', {
        description => "Execute static analisis to C/C++, Java and C# source",
        value => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/coverity_forms/wizardCustomEditor]'
    });
    
} elsif ($promoteAction eq 'demote') {
    $batch->deleteProperty("/server/ec_customEditors/pluginStep/coverity");
}
