package fishermanjoeandchildren.thewater.data;

//response code

public interface ResponseStatus {

    // HTTP Status 200
    String SUCCESS = "SU";

    // HTTP Status 400
    String VALIDATION_FAILED = "VF";
    String BAD_REQUEST = "BD";
    String NOT_FOUND = "NF";
    String NOT_FOUND_PAGE = "NP";

    // HTTP Status 401
    String SIGN_IN_FAIL = "SF";
    String AUTHROIZATION_FAILED = "AF";

    // HTTP Status 403
    String NO_PERMISSION = "NP";

    // HTTP Status 409
    String CONFLICT = "CF";

    // HTTP Status 500
    String DATABASE_ERROR = "DBE";

    String SERVER_ERROR = "SER";



}
