public without sharing class CreateProductHandler {

    @AuraEnabled(cacheable=true)
    public static List<String> getProductFields(String objectApiName) {
        List<String> fieldNames = new List<String>();
                Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        System.debug('fieldNames--->'+fieldNames);
        return fieldNames;
    }
}