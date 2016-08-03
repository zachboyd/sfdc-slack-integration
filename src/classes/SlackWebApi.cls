public with sharing class SlackWebApi {
	
    public class SlackMessage {
    	
        @InvocableVariable( label = 'Channel' required = true )
        public String channel;
        
        @InvocableVariable( label = 'Message' required = true )
        public String text;   
        
        @InvocableVariable( label = 'Post as User' required = true )
        public Boolean as_user;
        
        @InvocableVariable( label = 'Bot Name' description = 'Name of bot that this message should post as. Post As User must be false.' required = false )
        public String username;
        
    }
    
    @InvocableMethod( label = 'Post Message to Slack' )
    public static void postMessage( List<SlackMessage> messageList ) {
        
        SlackMessage message = messageList[0];  
        
	QueueableSlackCall call = new QueueableSlackCall( 
            'callout:Slack/chat.postMessage', 
            'POST', 
            createPostBody( message )
        );
                                                         
        System.enqueueJob( call );
        
    }
    
    private static String createPostBody( Object obj ) {
        
        // go ahead and add token to body. this uses merge parameters so the named credentials
        // must support merge parameters on the http body
        String body = 'token={!$Credential.OAuthToken}';
        
        // Convert object to map so we can iterate properties and append to body
    	Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( obj ) );
        
        if( objMap != null ) {
            
            for( String key : objMap.keySet() ) {                
                body += '&' + key + '=' + objMap.get( key );                
            }
            
        }
        
        System.debug( 'Body=' + body );
        
        return body;
        
    }
    
    /**
    * Class taken from http://coenraets.org/blog/2016/01/slack-salesforce-integration/
    */
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackCall( String url, String method, String body ) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute( System.QueueableContext ctx ) {
            
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint( url );
            req.setMethod( method );
            req.setBody( body );
            
            Http http = new Http();
            
            HttpResponse res = http.send( req );
            
        }
 
    }
    
}
