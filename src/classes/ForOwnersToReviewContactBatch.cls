public class ForOwnersToReviewContactBatch implements Database.Batchable<sObject>, Database.Stateful {


    static final String OUTDATED = 'Possible_Outdated__c = TRUE';
    static final String TEMPNAME = 'ContactOutdate';
    Map<Id, List<Contact>> contactsByOwnersMap = new Map<ID, List<Contact>>();
    Set<Id> OwnersIdset = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String contactQuery = 'SELECT '+
                'Name,'+
                'AccountId,'+
                'OwnerId,'+
                'Phone'+
                ' FROM '+
                'Contact '+
                'Where '+ OUTDATED;
        return Database.getQueryLocator(contactQuery);
    }

    public void execute(Database.BatchableContext bc, List<Contact> records) {

        for (Integer i = 0; i < records.size(); i++) {
            OwnersIdset.add(records[i].OwnerId);
        }

        for (Id owner : OwnersIdset) {
            List<Contact> contacts = new List<Contact>();
            for (Contact contact : records) {
                contacts.add(contact);
                if (Contact.OwnerId == owner) {
                    contactsByOwnersMap.put(Contact.OwnerId, contacts);
                } else {
                    OwnersIdset.add(owner);
                    contactsByOwnersMap.put(Contact.OwnerId, contacts);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {


        Messaging.SingleEmailMessage[] messages;

        for (Id owner : OwnersIdset) {
            List<String> owners = new List <String> {
                    owner
            };

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String subjectValue = 'The list of possible outdated Contacts that needs review!';
            String bodyValue = 'Contacts that need review: ';
            for (Contact con : contactsByOwnersMap.get(owner)) {
                bodyValue += '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+con.id+'">Contact</a>';
            }
            mail.setToAddresses( owners );
            mail.setSubject(subjectValue);
            mail.setHtmlBody(bodyValue);

            messages = new List<Messaging.SingleEmailMessage> {
                    mail
            };

        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if( results != null ){


            System.debug(LoggingLevel.ERROR, 'The email has not to send');
        }
    }
}