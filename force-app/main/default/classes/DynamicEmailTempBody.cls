public class DynamicEmailTempBody {
    
    @AuraEnabled
    public static String ParseDynamicEmailTempBody(string EmailTembody, Id recId){
        string UpdatedStringAfterReplacement;
        try{
            
            map<String, List<String>> mapofSobjectWithListofField = new map<String, List<String>>();
            List<String> listofSobjectAndField = new list<String>();
            list<String> listofFields;
            Set<String> sStrings;
            if(!String.isBlank(EmailTembody)){
                Pattern p = Pattern.compile('\\{!.+?\\}');
                //string templateContent = 'hello adrian , this is for {!Contact.Name} to be delivered to {!Account.Name}';
                
                Matcher m = p.matcher(EmailTembody);
                while(m.find()){
                    String mergeLiteral = m.group(0);
                    System.debug('--- Merge field '+ mergeLiteral);
                    String trimmedLiteral = mergeLiteral.replace('{!', '');
                    trimmedLiteral = trimmedLiteral.replace('}', '');
                    List<string> splitedtrimmedLiteral = trimmedLiteral.split('\\.');
                    system.debug('splitedtrimmedLiteral :: ' + splitedtrimmedLiteral);
                    system.debug('splitedtrimmedLiteral :: ' + String.valueOf(splitedtrimmedLiteral[1]));
                    
                    if(mapofSobjectWithListofField.containsKey(splitedtrimmedLiteral[0])){
                        listofFields = mapofSobjectWithListofField.get(splitedtrimmedLiteral[0]);
                        listofFields.add(String.valueOf(splitedtrimmedLiteral[1]));
                        sStrings = new Set<String>(listofFields);
                        system.debug('sStrings ====> ' + sStrings);
                        List<String> lStrings = new List<String>(sStrings);
                        mapofSobjectWithListofField.put(splitedtrimmedLiteral[0], lStrings);
                    }
                    else{
                        listofFields = new list<string>();
                        listofFields.add(String.valueOf(splitedtrimmedLiteral[1]));
                        system.debug('listofFields :: ' + listofFields);
                        sStrings = new Set<String>(listofFields);
                        system.debug('sStrings ====> ' + sStrings);
                        List<String> lStrings = new List<String>(sStrings);
                        mapofSobjectWithListofField.put(splitedtrimmedLiteral[0], lStrings);
                    }
                }
                system.debug('map of Sobject With List of Field :: ' + mapofSobjectWithListofField);
            }
            
            List<String> DatabaseQueryString = new List<String>();
            
            system.debug('mapofSobjectWithListofField.keySet() :: ' + mapofSobjectWithListofField.keySet());
            system.debug('mapofSobjectWithListofField.keySet() :: ' + mapofSobjectWithListofField.size());
            integer i = 1;
            List<sObject>  sObjlist = new List<sObject>();
            for(String listOfObjectAskey : mapofSobjectWithListofField.keySet()){
                string QueryString;
                string SobjectAPIName = listOfObjectAskey;
                i++;
                system.debug('i=='+i+'---listOfObjectAskey  '+listOfObjectAskey);
                system.debug('listOfObjectAskey :: ' + listOfObjectAskey);
                system.debug('mapofSobjectWithListofField.get(listOfObjectAskey) :: ' + mapofSobjectWithListofField.get(listOfObjectAskey));
                
                if(mapofSobjectWithListofField.get(listOfObjectAskey) != Null){
                    QueryString = 'SELECT ';
                    Schema.SObjectType objType = recId.getSobjectType();
                    
                    if(SobjectAPIName == String.valueOf(objType)){
                        list<String> listofFieldsOfSobject = mapofSobjectWithListofField.get(listOfObjectAskey);
                        String StringToJoin = String.join(listofFieldsOfSobject,',');
                        QueryString = QueryString + StringToJoin;
                        QueryString = QueryString + ' FROM ' + SobjectAPIName + ' Where Id = ' + '\''+ recId + '\'';
                        system.debug('QueryString :: ' + QueryString);
                        DatabaseQueryString.add(QueryString);  
                    }
                } 
                
            }
            system.debug('DatabaseQueryString :: ' + DatabaseQueryString);
            Map<String,Sobject> SobjectNameWithRecord = new Map<String,Sobject>();
            for(String str : DatabaseQueryString){
              sObject  sObj = Database.query(str);
                String sObject_APIName = String.valueOf(sObj.id.getSObjectType());
                SobjectNameWithRecord.put(sObject_APIName, sObj);
                //sObjlist.add(sObj);
            }
            system.debug('Sobject Name With Record :: ' + SobjectNameWithRecord);
            Map<string, String> mapOfMergeFieldWithValues = new Map<string, String>();
            
            for(string str : mapofSobjectWithListofField.keySet()){
                if(SobjectNameWithRecord.containsKey(str)){
                    for(string newstr : mapofSobjectWithListofField.get(str)){
                        string mergefieldTobeReplaced = '{!'+str+'.'+newstr+'}';
                        system.debug('merge field To be Replaced :: ' + mergefieldTobeReplaced);
                        mapOfMergeFieldWithValues.put(mergefieldTobeReplaced, String.ValueOf(SobjectNameWithRecord.get(str).get(newstr)));
                    }
                }
            }
            system.debug('mapOfMergeFieldWithValues  :: ' + mapOfMergeFieldWithValues);
            UpdatedStringAfterReplacement = EmailTembody;
            system.debug('UpdatedStringAfterReplacement :: ' + UpdatedStringAfterReplacement);
            for(String stringTobeReplaced : mapOfMergeFieldWithValues.keySet()){
                system.debug('stringTobeReplaced :: ' + stringTobeReplaced);
                if(mapOfMergeFieldWithValues.get(stringTobeReplaced) == NULL){
                    UpdatedStringAfterReplacement = UpdatedStringAfterReplacement.replace(stringTobeReplaced, '');
                }
                else{
                    UpdatedStringAfterReplacement = UpdatedStringAfterReplacement.replace(stringTobeReplaced, mapOfMergeFieldWithValues.get(stringTobeReplaced));
                }
                
                
            }
            System.debug('Updated String After Replacement :: ' + UpdatedStringAfterReplacement);
            return UpdatedStringAfterReplacement;
        }
        catch(Exception e){
            system.debug('e.get line number ' + e.getLineNumber() + 'message :: ' + e.getMessage() );
        }
        return UpdatedStringAfterReplacement;
    }

}