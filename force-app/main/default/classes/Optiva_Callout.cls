public without sharing class Optiva_Callout {
    public static Map<String,String> projectCreation(String recId){
        return OptivaCalloutHandler.getInstance().projectCreationHandler(recId);
    }

    public static Map<String,String> applicationCreation(String recId){
        return OptivaCalloutHandler.getInstance().applicationCreationHandler(recId);
    }

    public static Map<String,String> sampleCreation(String recId){
        return OptivaCalloutHandler.getInstance().sampleCreationHandler(recId);
    }

    public static Map<String,String> techDocCreation(String recId){
        return OptivaCalloutHandler.getInstance().techDocHandler(recId);
    }
}