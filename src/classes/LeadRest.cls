@RestResource(urlMapping='/Lead')
global with sharing class LeadRest {

    @HttpPost
    global static String getLeadReq(){

        String lead = LeadRest.leadManager(LeadRest.getRest());

        if (lead != null){
            return lead;
        } else {
            return 'Lead NOT Found';
        }
    }

    @HttpPut
    global static String taskForLead(){

        Task task;

        String leadId = (String) LeadRest.leadManager(LeadRest.getRest());

        Map<String, Object> taskforlead = LeadRest.getRest();
        Map<String, String> description = (Map<String, String> ) taskforlead.get('Description');


        for(String key: description.keySet()){
            String value= description.get(key);
            if(leadId != null && value != null){
                task=New Task(
                        Description = value,
                        WhoId = leadId
                );
            }else{
                System.debug(LoggingLevel.ERROR, 'Could not create task');

                return 'Could not create task without Name (Lead/Case)';
            }
        }
        insert task;

        return 'Task has been created';

    }

    public static String LeadManager (Map<String, Object> result){
        String empty = ' ';
        Integer idLengthOne = 18;
        Integer idLengthTwo = 15;
        Lead leadPassedResult;
        Lead resultById;

        try{
            String idResult = result.get('id') != empty ?
                    '%' + result.get('id').toString() + '%'
                    : empty;
            String emailResult = result.get('email') != empty ?
                    '%' + result.get('email').toString() + '%'
                    : empty;
            Boolean idValue = idResult.length() == idLengthOne|| idResult.length() == idLengthTwo && Pattern.matches('^[a-zA-Z0-9]*$', idResult);
            Boolean emailValue = Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', emailResult);

            System.debug('here123');
            System.debug(idResult != empty);
            System.debug(idValue);
            if(idResult != empty && idValue){
                System.debug('here');
                resultById = [
                        SELECT
                                Name,
                                Description
                        FROM Lead
                        WHERE Id = :idResult
                        ORDER BY Name
                        LIMIT 1
                ];
                System.debug(resultById);
                return  'resultById';
            }

            if (resultById == null && emailResult != empty && emailValue) {
                leadPassedResult = [
                        SELECT
                                Name,
                                Description
                        FROM Lead
                        WHERE Id = :emailResult
                        ORDER BY Name
                        LIMIT 1
                ];
            } else {
                System.debug(LoggingLevel.ERROR, 'Lead NOT Found');
                return 'Lead NOT Found';
            }
            return 'leadPassedResult';

        } catch (NullPointerException ex) {
            System.debug(LoggingLevel.INFO, 'EROR');
            return ex.getMessage();
        }

    }

    public static Map< String, Object > getRest(){

        RestRequest restRequest = RestContext.request;


        String reqToString = restRequest.requestBody.toString();

        Map<String, Object> result = (Map<String, Object>)
                JSON.deserializeUntyped(reqToString);
        return result;
    }


}