public class TestingClass {
    public static void ParseDynamicEmailTempBody(string EmailTembody){
        
        List<String> listofSobjectAndField = new list<String>();
        if(!String.isBlank(EmailTembody)){
            Pattern p = Pattern.compile('\\{!.+?\\}');
            //string templateContent = 'hello adrian , this is for {!Contact.Name} to be delivered to {!Account.Name}';
            
            Matcher m = p.matcher(EmailTembody);
            while(m.find()){
                String mergeLiteral = m.group(0);
                System.debug('--- Merge field '+ mergeLiteral);
                String trimmedLiteral = mergeLiteral.replace('{!', '');
                trimmedLiteral = trimmedLiteral.replace('}', '');
                //listofSobjectAndField.add(m.group(1));
                listofSobjectAndField.add(trimmedLiteral);
            }
            
            system.debug('listofSobjectAndField :: ' + listofSobjectAndField);
            
            Iterator<String> sObjAndField = listofSobjectAndField.iterator();
            while(sObjAndField.hasNext()){
                String data = string.valueOf(sObjAndField);
                system.debug('data :: ' + data );
                String sObj = data.split('\\.')[0];
                String field = data.split('\\.')[0];
                system.debug(sObj+' '+field);
            }
            
        }
    }
    
}