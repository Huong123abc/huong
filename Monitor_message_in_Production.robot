*** Settings ***
Documentation      Create new patient with new MRN and new EMR appointment ID and this patient has no link PO
Library            SeleniumLibrary
Library            OperatingSystem
Library            Collections
Library            DateTime
Library            PythonKeywords.py
Library            SSHLibrary
Library            String
# Library            openpyxl
Library            ExcellentLibrary
Library            ExcelLibrary
Library    Process
Library    XML
Default Tags       positive
Test Teardown    Sleep    3


Suite Setup        Login To Fusebox
#...    Login To Fusebox
# Suite Setup     Run Keywords
# ...             Login To Fusebox    AND
# ...             Setup A


*** Variables ***
${LOGIN URL}    https://secure.fabricius-software.com/User/Login
${BROWSER}        Chrome
${HOST}                20.29.92.181
${USERNAME}            mirth_dev
${PASSWORD}            xQQM85bq!!
${PATH_SFTP_SIU}    /mirth_dev/Meditab/huong.ho/SIU/
${PATH_FOLDER_SIU}    D:/HuongHNU/HuongHNU/Tool/Auto/Production/S12/3/25/
${FILE_TYPE_MSG}    New Appointment (S12)
${SENDER_MSG}    Allergy Associates of the Palm Beaches - North Palm Beach
${LOCATION_MSG}    Allergy Associates of the Palm Beaches - North (Koterba)
# ${FILE_MSG}    SIU.txt


*** Test Cases ***

Choose message in HL7Tools
    [Documentation]    SIU_PROD_01	Verify that 1 transaction row for 1 message
    Find Messege in HL7 Tool Page
    
Location is Partner's account
    [Documentation]    SIU_PROD_02	Verify that message S12 can create new patient with MRN is the value of PID.18.1 field in message
    Set Global Variable    ${dict_Input}
    Go To    https://secure.fabricius-software.com/Patient?accountId=Ng__
    Title Should Be    Patients
    # Wait Until Element Is Visible    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[4]    timeout=60
    Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div[1]/div/div/button
    Click Element    //*[@id="body"]/div/div[2]/div[1]/div/div/button
    Input Text    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input    ${LOCATION_MSG}
    Press Keys    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input    RETURN
    Sleep    15
    # Find Patient in Patient Page

Value of Find patient tab is PID.18.1 
    [Documentation]    SIU_PROD_03	Verify that Value of Find patient tab is PID.18.1
    Input Text    //*[@id="SearchValues"]    ${dict_Input}[PID-1][18]        #${dict_Input}[PID-1][18]
    Sleep    2
    Press Keys    //*[@id="SearchValues"]    RETURN
    Sleep    2
    Wait Until Element Is Not Visible    //*[@id="loading-indicator"]    timeout=90
    Sleep    20
    ${right_MRN}=    Set Variable    ${dict_Input}[PID-1][18]
    Set Global Variable    ${right_MRN}
    
MRN PID.18.1 in Patients
    [Documentation]    SIU_PROD_04	Verify that MRN is PID.18.1
    Element Should Contain    //table//tbody//tr//td[normalize-space(text())="${right_MRN}"]    ${dict_Input}[PID-1][18]        #${dict_Input}[PID-1][18]
    ${element_Number_of_patient}=    Get WebElement     //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[2]/a
    ${str_Number_of_patient}=    Get Text    ${element_Number_of_patient}
    Set Suite Variable    ${str_Number_of_patient}
    

The number of patient
    [Documentation]    SIU_PROD_05	Verify that MRN has 1 patient only
    Set Global Variable    ${right_MRN}
    ${element_Right_patient}=    Get WebElement    //table//tbody//tr//td[normalize-space(text())="${right_MRN}"]


Date of birth PID.7.1 in Patients Page
    [Documentation]    SIU_PROD_06	Verify that message S12 can create new patient with the date of birth is the value of PID.7.1 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Birth_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][7]    1
    Element Should Contain    //table//tbody//tr[td[normalize-space(text())="${right_MRN}"]]//td[@class="CenterAll"][3]    ${str_Birth_Input}[-4:-2]/${str_Birth_Input}[-2:]/${str_Birth_Input}[:4]

Phone PID.13.1 in Patients Page
    [Documentation]    SIU_PROD_07	Verify that message S12 can create new patient with the phone is the value of PID.13.1 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Phone_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][13]    1
    ${str_Phone_Input}=    Replace String Using Regexp    ${str_Phone_Input}    [-\(\) ]    ${EMPTY}
    # ${str_Phone}=    Get Element Attribute    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[5]/div[1]    data-original-title
    ${str_Phone}=    Get Element Attribute    //table//tbody//tr[td[normalize-space(text())="${right_MRN}"]]//td[@class="CenterAll"][5]//div[@class="col-xs-6 text-center"][1]    data-original-title
    Should Be Equal As Strings    ${str_Phone}    ${str_Phone_Input}

Email address PID.13.4 in Patients Page
    [Documentation]    SIU_PROD_08	Verify that message S12 can create new patient with the email address is the value of PID.13.4 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Email_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][13]    4
    # ${str_Email}=    Get Element Attribute    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[5]/div[2]    data-original-title
    ${str_Email}=    Get Element Attribute    //table//tbody//tr[td[normalize-space(text())="${right_MRN}"]]//td[@class="CenterAll"][5]//div[@class="col-xs-6 text-center"][2]    data-original-title
    IF    '${str_Email}' == 'No Email Available'
        Should Be Equal As Strings    '${str_Email_Input}'    ''
    ELSE
        Should Be Equal As Strings    '${str_Email_Input}'    '${str_Email}'
    END

Gender PID.8.1 in Patients Page
    [Documentation]    SIU_PROD_09	Verify that message S12 can create new patient with the gender is the value of PID.8.1 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Gender_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][8]    1
    ${str_Gender}=    Get Text    //table//tbody//tr[td[normalize-space(text())="${right_MRN}"]]//td[@class="CenterAll"][6]
    Should Contain    ${str_Gender}    ${str_Gender_Input}


Last update is processed in Patients Page
    [Documentation]    FB_07	Verify that message S12 can create new patient with the last update is the time when message is processed
    Set Global Variable    ${right_MRN}
    # ${str_Last_Update}=    Get Text    //*[@id="PatientList"]/div[2]/table/tbody/tr[2]/td/div[1]
    # ${str_Last_Update}=    Replace String Using Regexp    ${str_Last_Update}    Last Updated:${SPACE}    ${EMPTY}
    # ${date_Last_Update}=    Convert Date    ${str_Last_Update}    epoch    date_format=%m/%d/%Y at %H:%M %p
    # ${date_Last_Processed_Msg}=    Convert Date    ${date_Last_Processed_Msg}    epoch    date_format=%m/%d/%Y at %H:%M %p
    # Should Be Equal As Strings    ${str_Last_Update}    ${date_Last_Processed_Msg}
   
Number of Addresses is "1" in Patients Page
    [Documentation]    SIU_PROD_10	Verify that message S12 can create new patient in which the Addressed item is "1"
    # Element Should Contain    //*[@id="PatientList"]/div[2]/table/tbody/tr[2]/td/div[2]/a[1]/span    1
    Element Should Contain    //table//tbody[tr[td[normalize-space(text())="${right_MRN}"]]]//tr[2]//td//div[2]//a[1]//span    1

Number of Provider Order in Patients Page
    [Documentation]    SIU_PROD_11	Verify that message S12 can create new patient in which the Addressed item is "1"
    Element Should Contain    //table//tbody[tr[td[normalize-space(text())="${right_MRN}"]]]//tr[2]//td//div[2]//a[4]//span    Provider Orders


Number of Scheduled Appointments is "1" in Patients Page
    [Documentation]    SIU_PROD_12	Verify that message S12 can create new patient in which the Scheduled Appointments item is "1"
    # Element Should Contain    //*[@id="PatientList"]/div[2]/table/tbody/tr[2]/td/div[2]/a[5]/span    Scheduled Appointments
    Element Should Contain    //table//tbody[tr[td[normalize-space(text())="${right_MRN}"]]]//tr[2]//td//div[2]//a[5]//span    Scheduled Appointments

Patient information is divided into items
    [Documentation]    FB_10	Verify that the patient information page will be display when clicking on the sequence of digits in Patient page
    Go Update A Patient page
    
First name PID.5.2 in Patient Identifiers
    [Documentation]    SIU_PROD_18	Verify that information of first name in the patient information page is the value of PID.5.2 in message
    Set Suite Variable    ${dict_Input}
    ${str_First_Name_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][5]    2
    Element Attribute Value Should Be    //*[@id="FirstName"]    value    ${str_First_Name_Input}

Last name PID.5.1 in Patient Identifiers
    [Documentation]    SIU_PROD_19	Verify that information of last name in the patient information page is the value of PID.5.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Last_Name_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][5]    1
    Element Attribute Value Should Be    //*[@id="LastName"]    value    ${str_Last_Name_Input}

Medical record # PID.18.1 in Patient Identifiers
    [Documentation]    SIU_PROD_20	Verify that information of medical record # in the patient information page is the value of PID.18.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Medical_Record_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][18]    1
    Element Attribute Value Should Be    //*[@id="MRN"]    value    ${str_Medical_Record_Input}

Date of birth PID.7.1 in Patient Identifiers
    [Documentation]    SIU_PROD_21	Verify that information of date of birth in the patient information page is the value of PID.7.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Date_Of_Birth_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][7]    1
    Element Attribute Value Should Be    //*[@id="DOB"]    value    ${str_Date_Of_Birth_Input}[-4:-2]/${str_Date_Of_Birth_Input}[-2:]/${str_Date_Of_Birth_Input}[:4]

Social security PID.19.1 in Patient Identifiers
    [Documentation]    SIU_PROD_22	Verify that information of social security in the patient information page is the value of PID.19.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Social_Security_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][19]    1
    ${str_Social_Security}=    Get Value    //*[@id="SSN"]
    ${str_Social_Security}=    Replace String Using Regexp    ${str_Social_Security}    [-\(\) ]    ${EMPTY}    
    Should Be Equal    ${str_Social_Security}    ${str_Social_Security_Input}

Gender PID.8.1 in Patient Identifiers
    [Documentation]    SIU_PROD_24	Verify that information of gender in the patient information page is the value of PID.8.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Gender_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][8]    1
    IF   '${str_Gender_Input}' =='M'
        ${str_Gender_Input}=    Set Variable    Male
    END

    IF   '${str_Gender_Input}' =='F'
        ${str_Gender_Input}=    Set Variable    Female
    END

    IF   '${str_Gender_Input}' =='O'
        ${str_Gender_Input}=    Set Variable    Other
    END

    IF   '${str_Gender_Input}' ==''
        ${str_Gender_Input}=    Set Variable    Other
    END

    List Selection Should Be    //*[@id="Gender"]    ${str_Gender_Input}

Race PID.10.1 in Patient Identifiers
    [Documentation]    SIU_PROD_23	Verify that information of race in the patient information page is the value of PID.10.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Race_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][10]    1
    # List Selection Should Be    //*[@id="Race"]    ${str_Race_Input}

Marital status PID.16.1 in Patient Identifiers
    [Documentation]   SIU_PROD_25	Verify that information of marital status in the patient information page is the value of PID.16.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Marital_Status_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][16]    1
    Element Should Contain    //*[@id="MaritalStatus"]    ${str_Marital_Status_Input}

Personal home phone PID.13.1 in Personal Information
    [Documentation]    SIU_PROD_26	Verify that information of personal/ home phone in the patient information page is the value of PID.13.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Personal_Home_Phone_Input_1}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][13]    1
    ${str_Personal_Home_Phone_Input}=    Remove String    ${str_Personal_Home_Phone_Input_1}    -\    \(    \)    \ \    
    # ${str_Personal_Home_Phone_Input}=    Set Variable    1111111111
    ${phone}=    Get Value    //*[@id="Phone"]
    ${home_Phone}=    Remove String    ${phone}    -\    \(    \)    \ \
    Should Be Equal    ${str_Personal_Home_Phone_Input}    ${home_Phone}

Email PID.13.4 in Personal Information
    [Documentation]    SIU_PROD_27	Verify that information of email in the patient information page is the value of PID.13.4 in message
    Set Suite Variable    ${dict_Input}
    ${str_Email_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][13]    4
    Element Attribute Value Should Be    //*[@id="Email"]    value    ${str_Email_Input}

Work phone PID.14.1 in Personal Information
    [Documentation]    SIU_PROD_28	Verify that information of work phone in the patient information page is the value of PID.14.1 in message
    Set Suite Variable    ${dict_Input}
    ${str_Email_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][13]    4
    Element Attribute Value Should Be    //*[@id="Email"]    value    ${str_Email_Input}

Default address PID.11 in Patient Addresses
    [Documentation]    SIU_PROD_29	Verify that information of default address in the patient information page is the value of PID.11 in message
    Set Suite Variable    ${dict_Input}
    ${str_Default_Addressr_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    1
    Element Should Contain    //*[@id="PrimaryAddress"]    ${str_Default_Addressr_Input}

Address Line 1 is PID.11.1 in Patient Addresses
    [Documentation]    SIU_PROD_30	Verify that information of default address in the patient information page is the value of PID.11 in message
    Set Suite Variable    ${dict_Input}
    ${str_Default_Addressr_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    1
    ${address_1}=    Get Value    //div[@id="DefaultAddressReadOnly"]//div[@class="form-group"][1]//input[@autocomplete="off"]
    Should Be Equal    ${str_Default_Addressr_Input}    ${address_1}

Address Line 2 is PID.11.2 in Patient Addresses
    [Documentation]    SIU_PROD_31	Verify that information of default address in the patient information page is the value of PID.11 in message
    Set Suite Variable    ${dict_Input}
    ${str_Default_Addressr_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    2
    ${address_2}=    Get Value    //div[@id="DefaultAddressReadOnly"]//div[@class="form-group"][2]//input[@autocomplete="off"]
    Should Be Equal    ${str_Default_Addressr_Input}    ${address_2}

City is PID.11.3 in Patient Addresses
    [Documentation]    SIU_PROD_32	Verify that information of default address in the patient information page is the value of PID.11 in message
    Set Suite Variable    ${dict_Input}
    ${str_Default_Addressr_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    3
    ${address_City}=    Get Value    //div[@id="DefaultAddressReadOnly"]//div[@class="row"]//div[@class="form-group col-sm-6"]//input[@autocomplete="off"]
    Should Be Equal    ${str_Default_Addressr_Input}    ${address_City}

State is PID.11.5 in Patient Addresses
    [Documentation]    SIU_PROD_33	Verify that information of default address in the patient information page is the value of PID.11 in message
    Set Suite Variable    ${dict_Input}
    ${str_Default_Addressr_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    4
    ${address_State}=    Get Value    //div[@id="DefaultAddressReadOnly"]//div[@class="row"]//div[@class="form-group col-sm-3"][1]//input[@autocomplete="off"]
    Should Be Equal    ${str_Default_Addressr_Input}    ${address_State}


Zip code is PID.11.4 in Patient Addresses
    [Documentation]    SIU_PROD_34	Verify that information of default address in the patient information page is the value of PID.11 in message
    Set Suite Variable    ${dict_Input}
    ${str_Default_Addressr_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    5
    ${address_Zip_code}=    Get Value    //div[@id="DefaultAddressReadOnly"]//div[@class="row"]//div[@class="form-group col-sm-3"][2]//input[@autocomplete="off"]
    Should Be Equal    ${str_Default_Addressr_Input}    ${address_Zip_code}

Patient address page will be displayed in Addresses
    [Documentation]    SIU_PROD_13	Verify that the patient address page will be displayed when clicking on the Addresses item in Patient page
    Go Addresses Tab

# Patient address page is same PID.11 in Addresses
#     Go Addresses Tab
#     [Documentation]    FB_24	Verify that information in the patient address page is same as value of PID.11 field in message
#     Set Suite Variable    ${dict_Input}
#     ${str_Address_1}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    1
#     ${str_Address_3}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    3
#     ${str_Address_4}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    4
#     ${str_Address_5}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    5
#     Element Text Should Be    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[2]    ${str_Address_1}
#     Element Text Should Be    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[3]    ${str_Address_3}
#     Element Text Should Be    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[4]    ${str_Address_4}
#     Element Text Should Be    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[5]    ${str_Address_5}

Patient address line is same PID.11.1 and PID.11.2 in Addresses
    [Documentation]    SIU_PROD_14	Verify that information in the patient address page is same as value of PID.11 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Address_1}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    1
    Element Should Contain    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[2]    ${str_Address_1}

City is same PID.11.3 in Addresses
    [Documentation]    SIU_PROD_15	Verify that information in the patient address page is same as value of PID.11 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Address_3}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    3
    Element Should Contain    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[3]    ${str_Address_3}

State is same PID.11.5 in Addresses
    [Documentation]    SIU_PROD_16	Verify that information in the patient address page is same as value of PID.11 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Address_4}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    4
    Element Should Contain    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[4]    ${str_Address_4}

Zip code is same PID.11.4 in Addresses
    [Documentation]    SIU_PROD_17	Verify that information in the patient address page is same as value of PID.11 field in message
    Set Suite Variable    ${dict_Input}
    ${str_Address_5}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][11]    5
    Element Should Contain    //*[@id="AddressTabList"]/div[2]/div/div/table/tbody/tr/td[5]    ${str_Address_5}

#Scheduled Appointment in patient page
Scheduled Appointment displayed in Scheduled Appointments
    [Documentation]    FB_25	Verify that the Scheduled Appointment page will be displayed when clicking on the Scheduled Appointment item in Patient page
    Go Scheduled Appointments Tab

Number of patient is same in Patient 
    [Documentation]    SIU_PROD_35	Verify that the number of patient is same as that in Patient page
    Set Suite Variable    ${str_Number_of_patient}
    Element Should Contain    ${element_String_number}    ${str_Number_of_patient}

Time of appointment is same as value of SCH.11.4 in message
    [Documentation]    SIU_PROD_36	Verify that time of appointment is same as value of SCH.11.4 in message
    Set Suite Variable    ${dict_Input}
    ${str_Time_of_appointment_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[SCH-1][11]    4
    ${date_Time_of_appointment_Input}=    Convert Date    ${str_Time_of_appointment_Input}    epoch    date_format=%Y%m%d%H%M
    ${str_Date_of_appointment}=    Get Text    ${element_Date_of_appointment}
    ${str_Time_of_appointment}=    Get Text    ${element_Time_of_appointment}
    ${date_Time_of_appointment}=    Convert Date    ${str_Date_of_appointment} ${str_Time_of_appointment}    epoch    date_format=%m/%d/%Y %I:%M %p
    Should Be Equal    ${date_Time_of_appointment}    ${date_Time_of_appointment_Input}

View HL7
    [Documentation]    SIU_PROD_37	Verify that the number of patient is same as that in Patient page
    Set Suite Variable    ${str_Number_of_patient}

Link to PO
    [Documentation]    SIU_PROD_38	Check information that involved in PO
    Go Provider Orders Tab
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}    
    #     IF    ${bool_1} == ${True}
            Set Global Variable    ${number_PO}
            Element Should Contain    ${element_PO_link}    ${number_PO}
        ELSE
            Element Should Not Contain    ${element_PA}    PO
            
        END

PA status
    [Documentation]    SIU_PROD_39	Check information that involved in PO
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}    
    #     IF    ${bool_1} == ${True}
            Element Should Contain    ${element_PA}    PA:         #Assigned
        ELSE
            Element Should Contain    ${element_PA}    PA:     #Not Assigned
            
        END

DOB is corresponding PID.7.1 in message 
    [Documentation]    SIU_PROD_40	Verify that the DOB is corresponding to the value of PID.7.1 field in message 
    Set Suite Variable    ${dict_Input}
    ${str_DOB_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][7]    1
    ${str_Year_Current}=    Get Current Date    result_format=%Y    #%m%d
    ${str_DOB_Year_Input}=    Evaluate    ${str_Year_Current} - ${str_DOB_Input}[:4]
    Element Should Contain    ${element_str_DOB}    ${str_DOB_Year_Input}
 

MRN is same PID.18.1 in message 
    [Documentation]    SIU_PROD_41	Verify that the MRN is same as the value of PID.18.1 field in message 
    Set Suite Variable    ${dict_Input}
    ${str_MRN_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][18]    1
    Element Should Contain    ${element_MRN}    ${str_MRN_Input}
    
Service type      
    [Documentation]    SIU_PROD_42	Verify that the MRN is same as the value of PID.18.1 field in message 
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    Set Suite Variable    ${dict_Input}
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}    
    #     IF    ${bool_1} == ${True}
            Element Should Contain    ${element_Service_type}    ${service_Type}    ignore_case=${True}
        ELSE
            Element Should Contain    ${element_Service_type}    BUY AND BILL    ignore_case=${True}
        END    

DX Code
    [Documentation]    SIU_PROD_43	Verify that the MRN is same as the value of PID.18.1 field in message 
    Set Suite Variable    ${dict_Input}
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}    
    #     IF    ${bool_1} == ${True}
            ${code}=    Get Text    ${element_ICD_code}    
            Should Be Equal    ${code}    ${icd_ Code}
        ELSE
            ${code}=    Get Text    ${element_ICD_code}
            Element Should Contain    ${element_ICD_code}    N/A
        END   

Medication
    [Documentation]    SIU_PROD_44	Verify that the MRN is same as the value of PID.18.1 field in message 
    Set Suite Variable    ${dict_Input}
    ${str_Medication_name_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[AIS-1][3]    2
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}    
    #     IF    ${bool_1} == ${True}
            Should Contain    ${dosage}    ${dosage_2}    ignore_case=True
        ELSE
            Should Contain    ${str_Medication_name_Input}    ${medication_1}    ignore_case=True
        END   
   

Medication dosage
    [Documentation]    SIU_PROD_45	Verify that the medication name is same as value of AIS.3.2 in message
    Set Suite Variable    ${dict_Input}
    ${str_Medication_name_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[AIS-1][3]    2
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}    
    #     IF    ${bool_1} == ${True}
            Element Should Contain    ${element_str_Medication}    ${element_Dosage}

        END
    

Refer to provider is same as value of PV1.7 in message
    [Documentation]    SIU_PROD_46	Verify that refer to provider is same as value of PV1.7 in message
    Set Suite Variable    ${dict_Input}
    ${str_Refer_to_provider_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PV1-1][7]    1
    List Selection Should Be    ${element_Refer_to_Provider}    ${str_Refer_to_provider_Input}
        # IF    ${str_Refer_to_provider_Input} == ${EMPTY}
        #     ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        #     IF    ${bool_2} == ${True} 
        #         List Selection Should Be    ${element_Refer_to_Provider}    ${refer_To _provider_In_po}
                
        #     END  
        # ELSE
        #     List Selection Should Be    ${element_Refer_to_Provider}    ${str_Refer_to_provider_Input}
             
        # END


Referring provider
    [Documentation]    SIU_PROD_47	Check information that involved in PO
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}
    #     IF    ${bool_1} == ${True}
            Element Should Contain    ${element_Referring_provider}    ${referring_Provider}                    
        END

#Open Appointments in Patient page
Scheduled Appointment displayed in Open Appointments  
    [Documentation]    FB_37.1	Verify that the Open Appointment page will be displayed when clicking on the Open Appointment item Scheduled Appointment in Patient page
    Go Open Appointments Tab
    Wait Until Element Is Visible    //*[@id="AppointmentItemTable"]/tbody/tr[1]/td/div    10
    # ${pop_UP}=    Get WebElement    //strong[contains(text(),"This therapy does not have a Provider Order associated.")]
    ${bool_Pop_up}=    Run Keyword And Return Status    Get WebElement    //*[@id="AppointmentItemTable"]/tbody/tr[1]/td/div 
        IF    ${bool_Pop_up} == ${True}                                
            Click Element    //div[@id="SubModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[@type="button"]
            Sleep    10
            
        END
        
Patient number in Open Appointment is same in Patient page
    [Documentation]    SIU_PROD_48	Verify that the number of patient is same as that in Patient page
    Set Suite Variable    ${str_Number_of_patient}
    Sleep    20
    Element Should Contain    //*[@id="_CurrentAppointmentTab"]/div[2]/div[2]/div[1]/div[1]/div    ${str_Number_of_patient}
    
DOB in Open Appointment is corresponding PID.7.1 in message 
    [Documentation]    SIU_PROD_49	Verify that the DOB is corresponding to the value of PID.7.1 field in message 
    Set Suite Variable    ${dict_Input}
    Sleep    20
    ${str_DOB_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][7]    1
    ${str_Year_Current}=    Get Current Date    result_format=%Y
    ${str_DOB_Year_Input}=    Evaluate    ${str_Year_Current} - ${str_DOB_Input}[:4]
    Element Should Contain    ${str_DOB}    ${str_DOB_Year_Input}

Gender PID.8.1 in Open AppointmentA
    [Documentation]    SIU_PROD_50	Verify that message S12 can create new patient with the gender is the value of PID.8.1 field in message
    Set Suite Variable    ${dict_Input}
    Sleep    20
    ${str_Gender_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PID-1][8]    1
    ${str_Gender}=    Get Text    //*[@id="_CurrentAppointmentTab"]/div[2]/div[2]/div[3]/div[1]
    Should Contain    ${str_Gender}    ${str_Gender_Input}

Patient height is default
    [Documentation]    SIU_PROD_51	Verify that the patient height is default
    Sleep    20
    Element Should Contain    //*[@id="PatientHeight"]    ${EMPTY}                

Appointment Location is default
    [Documentation]    SIU_PROD_52	Verify that the Appointment Location is default
    Sleep    20
    Element Should Contain    //*[@id="SiteOfCare"]    In Office     

Appointment time in Open Appointment
    [Documentation]    SIU_PROD_54	Verify that time of appointment is same as value of SCH.11.4 in message
    Set Suite Variable    ${dict_Input}
    Sleep    20
    ${str_Time_of_appointment_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[SCH-1][11]    4
    ${date_Time_of_appointment_Input}=    Convert Date    ${str_Time_of_appointment_Input}    epoch    date_format=%Y%m%d%H%M
    ${str_Date_of_appointment}=    Get Text    //*[@id="_CurrentAppointmentTab"]/div[4]/div[2]/strong
    ${date_Time_of_appointment}=    Convert Date    ${str_Date_of_appointment}    epoch    date_format=Appointment on %A, %B %d, %Y at %I:%M %p
    Should Be Equal    ${date_Time_of_appointment}    ${date_Time_of_appointment_Input}

Assigned DX code
    [Documentation]    SIU_PROD_55	Verify that assign to provider is same as value of PV1.7 in message
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}
    #     IF    ${bool_1} == ${True}
            Element Should Contain    //a[@class="btn btn-default btn-sm "]    ${icd_ Code}
        ELSE
            Element Should Contain    //a[@class="btn btn-warning btn-sm "]    Assign Code    
        END   

Assign provider is same as value of PV1.7.1
    [Documentation]    SIU_PROD_56	Verify that assign to provider is same as value of PV1.7 in message
    Set Suite Variable    ${dict_Input}
    Sleep    20
    ${str_Refer_to_provider_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[PV1-1][7]   0
    Element Should Contain    //*[@id="_CurrentAppointmentTab"]/div[5]/div[2]/a    ${str_Refer_to_provider_Input}    ignore_case=True
    #Element Should Contain    //*[@id="_CurrentAppointmentTab"]/div[5]/div[2]/a    ${str_Refer_to_provider_Input}

Primary Therapy in Patient page
    [Documentation]    SIU_PROD_57	Verify that assign to provider is same as value of PV1.7 in message
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}
    #     IF    ${bool_1} == ${True}
            Sleep    5
            Element Should Contain    //*[@id="Therapy"]    ${str_Of_dosage} 
            Element Should Contain    //*[@id="Therapy"]    ${number_PO} 
            Element Should Contain    //*[@id="Therapy"]    ${expiration_Date_of_PO}
            Element Should Contain    //*[@id="Therapy"]    ${medication_Only}                 
        ELSE
            Element Should Contain    //*[@id="Therapy"]    Unsaved Therapy
        END


Primary Medication in Patient page
    [Documentation]    SIU_PROD_57	Verify that assign to provider is same as value of PV1.7 in message
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
    # ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}
    #     IF    ${bool_1} == ${True}
            Sleep    3
            Element Should Contain    //div[@style="background-color: #337ab7; border-radius: 5px; padding: 7px;"]    ${str_Of_dosage} 
            Element Should Contain    //div[@style="background-color: #337ab7; border-radius: 5px; padding: 7px;"]    ${medication_Only}
            Element Should Contain    //*[@id="PrimaryMedicationBadge"]    1
        ELSE
            Element Should Contain    //*[@id="AppointmentItemTable"]/tbody/tr[1]/td/div    No Primary Medications Added
        END

#Calendar View Page 
Check Location in calendar
    [Documentation]   SIU_PROD_59	Verify that the appointment displays in calendar
    Go Calendar View Page  
    # Click Element    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
    # Input Text    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    100028    #Input Location
    # # //ul[@role="listbox"]//li//a//span[text()='${LOCATION_MSG} ']
    
    # Press Keys    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    RETURN
    # Sleep    10

Date range
    [Documentation]   SIU_PROD_60	Verify that the appointment displays in calendar
    Set Global Variable    ${apt_ID}
    # Input Text    //*[@id="StartDate"]    ${str_Date_of_appointment}        #Input Start date

    # Press Keys    //*[@id="StartDate"]    RETURN

    # Input Text    //*[@id="EndDate"]    ${str_Date_of_appointment}         #Input End Date

    # Press Keys    //*[@id="EndDate"]    RETURN
    # Wait Until Page Contains Element    //div[contains(@id,"main-calendar-loading-div")]    100
    # Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5
    # Sleep    10

Patient number    
    [Documentation]   SIU_PROD_61	Verify that the appointment displays in calendar
    @{elements_list_time}=    Get WebElements    //*[@id="mainview_calendar"]/div[2]/div[3]/table/tbody/tr[3]/td[2]/div/div[*]/div[1]
    @{elements_list_title}=    Get WebElements    //*[@id="mainview_calendar"]/div[2]/div[3]/table/tbody/tr[3]/td[2]/div/div[*]/div[4]

    FOR    ${index_title}    ${i_title}    IN ENUMERATE    @{elements_list_title}
        ${str_title}=    Get Text    ${i_title}
        ${str_time}=    Get Text    ${elements_list_time}[${index_title}]
        IF    '''${str_title}''' == '''${str_Number_of_patient}'''
            Log To Console    ${str_title}
            ${str_time}=    Convert To Upper Case    ${str_time}
    
            Set Suite Variable    ${index_title}
            BREAK
        END
        Log To Console    ${index_title}
    END
    Set Global Variable    ${str_time}

Appointment Start Time
    [Documentation]   SIU_PROD_61	Verify that the appointment displays in calendar
    Set Global Variable    ${apt_ID}
    # ${str_Time_of_appointment}=    Convert To Upper Case    ${str_Time_of_appointment}
    # ${str_Time_of_appointment}=    Convert Date    ${str_Date_of_appointment} ${str_Time_of_appointment}    epoch    date_format=%m/%d/%Y %H:%M %p  
    # ${str_time_1}=    Convert Date    ${str_Date_of_appointment} ${str_time}    epoch    date_format=%m/%d/%Y %H:%M %p
    # Should Be Equal As Strings    ${str_Time_of_appointment}    ${str_time_1}

# Check appointment in Ledger View page
#     [Documentation]   FB_ - FB_	Verify that the appointment displays in Ledger View page
#     Go Ledger View Page 
    
Appointment displayed in Ledger View
    [Documentation]    FB_108 - FB_132 - Verify that appointment displayed in Ledger View (go Patients page -> Update Patient page -> Appointments tab -> Appointment Odering Ledger page [Calendar view] -> Ledger view)  
    ##############Patients page
    #Set Global Variable    ${dict_Input}   
    Go To    https://secure.fabricius-software.com/Patient?accountId=Ng__    #https://fusebox-portal-vn.azurewebsites.net/Patient?accountId=Ng__
    Title Should Be    Patients
    #Wait Until Element Is Visible    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[4]    timeout=60
    #Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div[1]/div/div/button
    Click Element    //*[@id="body"]/div/div[2]/div[1]/div/div/button
    #Sleep    10
    #Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input
    Input Text    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input    ${LOCATION_MSG}    
    Sleep    5    #1
    Press Keys    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input    RETURN
    Sleep    5    #2
    Input Text    //*[@id="SearchValues"]    ${dict_Input}[PID-1][18]
    Sleep    2
    Press Keys    //*[@id="SearchValues"]    RETURN
    Sleep    2
    Wait Until Element Is Not Visible    //*[@id="loading-indicator"]    timeout=90
    Sleep    20
    Element Should Contain    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[4]    ${dict_Input}[PID-1][18]     
    ${MRN}    Set Variable    ${dict_Input}[PID-1][18]  
    Set Suite Variable    ${MRN}

    ##############Update Patient page [Appointments tab]
    ${element_Number_of_patient}=    Get WebElement     //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[2]/a
    ${str_Number_of_patient}=    Get Text    ${element_Number_of_patient}
    ${Number_of_patient}    Set Variable    ${str_Number_of_patient}
    Set Suite Variable    ${Number_of_patient}
    Set Suite Variable    ${str_Number_of_patient}    
    Wait Until Element Is Visible    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[2]/a
    Click Element    ${element_Number_of_patient}
    Title Should Be    Update Patient
    Element Should Contain    //*[@id="body"]/div/div[2]/div/h4    ${str_Number_of_patient}
    #Go To    https://fusebox-portal-vn.azurewebsites.net/Patient/Edit?patientId=MTk2ODU5&accountId=Mjg_&active=appointment
    Click Element    //*[@id="Appointment"]
    Sleep    10
    Wait Until Element Contains    //*[@id="AppointmentTabList"]    Scheduled Appointments
    ${str_Date_of_appointment}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[2]   
    ${Date_of_appointment}    Set Variable    ${str_Date_of_appointment}
    Set Suite Variable    ${Date_of_appointment}
    ${str_Time_of_appointment}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[3]   
    ${Time_of_appointment}    Set Variable    ${str_Time_of_appointment}   
    Set Suite Variable    ${Time_of_appointment}
    ${str_Time_of_appointment}=    Convert To Lower Case    ${str_Time_of_appointment}
    ${apmt_ID}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[1]/strong
    ${str_DOB}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[2]/div[3]/div[1]/div[1]/strong
    ${DOB}    Set Variable    ${str_DOB}
    Set Suite Variable    ${DOB}
    ${Service_Type}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[2]/div[3]/div[1]/div[3]/strong
    ${DX_Code}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[2]/div[4]/div[1]/strong
    Set Suite Variable    ${DX_Code}
    Wait Until Element Is Visible    xpath:/html/body/div[1]/div/form/div[1]/div[4]/div[12]/div/table/tbody/tr[3]/td[2]/div[5]/strong    
    ${Refer_to}=    Get Selected List Label    //*[@id="item_PhysicianId"]
    Set Suite Variable    ${Refer_to}
    ${Referring}=    Get Selected List Label    //*[@id="item_ReferringPhysicianID"]
    Set Suite Variable    ${Referring}
    ${str_Medication}    Get Text    xpath:/html/body/div[1]/div/form/div[1]/div[4]/div[12]/div/table/tbody/tr[3]/td[2]/div[5]/strong    #//*[@id="ApptMedColumn_Mzg4OTIz"]/strong   
    ${Medication}    Set Variable    ${str_Medication}
    Set Suite Variable    ${Medication}
    ${str_Status}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[5]/span
    ${view_HL7}=    Get WebElement    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[6]/span  
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${view_HL7}
    Sleep    5
    Wait Until Element Is Visible    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[1]/td[6]/a[1]
    ${view_HL7}=    Get WebElement    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[1]/td[6]/a[1]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${view_HL7}
    Sleep    10
    ${view_HL7}=    Get Text    //*[@id="file_DocumentText"]
    #Set Suite Variable    ${view_HL7}
    #Sleep    5
    Scroll Element Into View    //*[@id="ModalPopup"]/div[2]/div/div[3]
    Sleep    15
    #Wait Until Element Is Visible    /html/body/div[1]/div/div[4]/div[2]/div/div[3]/button[5]    timeout=15    #//*[@id="CloseBtn"]
    #Click Button    xpath:/html/body/div[1]/div/div[7]/div[2]/div/div[3]/button[5]
    ${close_btn}=    Get WebElement    xpath:/html/body/div[1]/div/div[4]/div[2]/div/div[3]/button[5]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${close_btn}    

    # Provider Orders tab

    # Prior Authorizations tab
    # ${PA_DX_Code}=    Get Text    //*[@id="PhysicianOrderTabList"]/div[1]/table/tbody/tr[1]/td[8]/div[1]
    # Should Be Equal    ${PA_DX_Code}    ${DX_Code}
    # ${PA}=    Get WebElement    //*[@id="PriorAuthorizationTabList"]/div[1]/table/tbody/tr
    # Execute Javascript    arguments[0].click();    ARGUMENTS    ${PA}
    # Wait Until Element Is Visible    //*[@id="PriorAuthorizationContent"]/div[2]/div[2]/div/a[1]
    # ${PA_DX_Code_2}=    Get Text    //*[@id="PriorAuthorizationContent"]/div[2]/div[2]/div/a[1]
    # Should Be Equal    ${PA_DX_Code_2}    ${PA_DX_Code}
    # Click Element    //*[@id="PriorAuthorizationTabList"]/div[1]/table/tbody/tr[1]
    # ${service_Type}=    Get Selected List Label    //*[@id="MedicationType"]
    # Log To Console    service type>>>>>>>>>>>>>>>>${service_Type}
    # ${PA_DX_Code_2}=    Get Text    //*[@id="PriorAuthorizationContent"]/div[2]/div[2]/div/a[1]
    # Scroll Element Into View    //*[@id="ModalPopup"]/div[2]/div/div[3]
    # Sleep    15
    # ${close_btn}=    Get WebElement    //*[@id="CloseBtn"]
    # Execute Javascript    arguments[0].click();    ARGUMENTS    ${close_btn}
    
    ######################Appointment Ordering Ledger page [Calendar view]
    Click Element    //*[@id="navbar-collapse"]/ul[1]/li[2]
    Click Element    //*[@id="navbar-collapse"]/ul[1]/li[2]/ul/li[2]/a
    Title Should Be    Appointment Ordering Ledger
    Wait Until Element Is Visible    //*[@id="appointmentViewsDropdown"]    timeout=30
    #Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
    Input Text    //*[@id="StartDate"]   ${str_Date_of_appointment}        #Input Start date
    Press Keys    //*[@id="StartDate"]    RETURN
    Input Text    //*[@id="EndDate"]    ${str_Date_of_appointment}         #Input End Date
    Press Keys    //*[@id="EndDate"]    RETURN
    Click Element    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
    Input Text    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    100028    #Input Location
    # //ul[@role="listbox"]//li//a//span[text()='${LOCATION_MSG} ']
    Press Keys    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    RETURN
    #Wait Until Page Contains Element    //div[contains(@id,"main-calendar-loading-div")]    100
    #Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5 
    
    #[Ledger view]
    #Click Element    xpath:/html/body/div[1]/div/div[3]/div/div[2]/div/button       
    #Click Element    //*[@id="LedgerViewElement"]    
    ${list_sub_page}=    Get WebElements    //*[@id="AppointmentList"]/div[3]/div[2]/a    
    ${num_sub_page}=    Get Length    ${list_sub_page}
    ${check_apmt}    Set Variable    ${False}
    ${check_page}=    Evaluate    0  
    WHILE    ${check_apmt} == ${False} 
        Sleep    30
        Wait Until Element Is Visible    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[1]/div[1]/strong
        ${list_apmt_ID}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[1]/div[1]/strong    
        ${len_list_apmt_ID}=    Get Length    ${list_apmt_ID}
        Log To Console    len list apmt id>>>>>>>>${len_list_apmt_ID}
        #Sleep    30
        FOR    ${i}    ${j}    IN ENUMERATE    @{list_apmt_ID}
            #Scroll Element Into View    //div[span[text()=" View HL7 "]]//ancestor::tbody//tr[${j+1}]
            Wait Until Page Contains Element    ${j}    #timeout=30
            Wait Until Element Is Visible    ${j}    #timeout=30
            ${text_apmt_ID}=    Get Text    ${j}      
            Log To Console    text apmt ID>>>>>>>${text_apmt_ID}    
            Log To Console    apmt ID>>>>>>>>>>>>${apmt_ID}  
            #Set List Value    ${list_apmt_ID}    ${j}    ${text_apmt_ID}
            #${check_apmt}=       Evaluate    "${apmt_ID}" in ${list_apmt_ID}
            IF    "${text_apmt_ID}" == "${apmt_ID}"            #${check_apmt} == ${True}
                ${list_Date_of_appointment}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[1]/div[2]/strong
                ${list_MRN}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[2]/div[2]/div[1]/div[2]/strong
                ${list_Number_of_patient}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[2]/div[1]/div[1]/strong
                ${list_Time_of_appointment}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[1]/div[3]/strong
                ${list_DOB}=     Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[2]/div[2]/div[1]/div[1]/strong
                ${list_Service_Type}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[2]/div[2]/div[1]/div[3]/strong
                ${list_DX_Code}=   Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[2]/div[3]/div[1]/strong
                ${list_Refer_to}=    Get WebElements  //*[@id="item_PhysicianId"]
                ${list_Referring}=    Get WebElements   //*[@id="item_ReferringPhysicianID"]             
                ${list_Medication}=    Get WebElements    xpath:/html/body/div[1]/div/div[4]/table/tbody/tr[*]/td[2]/div[4]/strong   
                ${list_View_HL7}=    Get WebElements    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[1]/div[6]/span 
                Execute Javascript    arguments[0].click();    ARGUMENTS    ${list_View_HL7}[${i}]
                #Click Button    ${list_View_HL7}[${i}]
                #Click Element    //*[@id="AppointmentList"]/table/tbody/tr[*]/td[1]/div[6]/span
                Wait Until Element Is Visible    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[1]/td[6]/a[1]
                ${text_view_HL7}=    Get WebElement    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[1]/td[6]/a[1]
                Execute Javascript    arguments[0].click();    ARGUMENTS    ${text_view_HL7}       
                Sleep    10            
                #Click Element    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[1]/td[6]/a[1]                   
                ${text_view_HL7}=    Get Text    //*[@id="file_DocumentText"]
                Set Suite Variable    ${text_view_HL7}
                #Sleep    5
                Scroll Element Into View    //*[@id="ModalPopup"]/div[2]/div/div[3]
                Sleep    15
                #Wait Until Element Is Visible    xpath:/html/body/div[1]/div/div[7]/div[2]/div/div[3]/button[5]    timeout=15    #//*[@id="CloseBtn"]
                #Click Element    xpath:/html/body/div[1]/div/div[7]/div[2]/div/div[3]/button[5] 
                ${close_btn}=    Get WebElement    xpath:/html/body/div[1]/div/div[7]/div[2]/div/div[3]/button[5]    
                Execute Javascript    arguments[0].click();    ARGUMENTS    ${close_btn}
                ${text_Date_of_appointment}=    Get From List    ${list_Date_of_appointment}    ${i}
                ${text_Date_of_appointment}=    Get Text    ${text_Date_of_appointment}
                Set Suite Variable    ${text_Date_of_appointment}               
                ${text_MRN}=    Get From List    ${list_MRN}    ${i}
                ${text_MRN}=    Get Text    ${text_MRN}
                Set Suite Variable    ${text_MRN}
                ${text_Number_of_patient}=    Get From List    ${list_Number_of_patient}    ${i}
                ${text_Number_of_patient}=    Get Text    ${text_Number_of_patient}
                Set Suite Variable    ${text_Number_of_patient}
                ${text_Time_of_appointment}=    Get From List    ${list_Time_of_appointment}    ${i}
                ${text_Time_of_appointment}=    Get Text    ${text_Time_of_appointment}
                Set Suite Variable    ${text_Time_of_appointment}
                ${text_DOB}=    Get From List    ${list_DOB}    ${i}
                ${text_DOB}=    Get Text    ${text_DOB}
                Set Suite Variable    ${text_DOB}                
                ${text_Service_Type}=    Get Text    ${list_Service_Type}[${i}]
                Set Suite Variable    ${text_Service_Type}
                ${text_DX_Code}=    Get Text    ${list_DX_Code}[${i}]
                Set Suite Variable    ${text_DX_Code}               
                ${text_Refer_to}=    Get Selected List Label    ${list_Refer_to}[${i}]
                Set Suite Variable    ${text_Refer_to}
                ${text_Referring}=    Get Selected List Label    ${list_Referring}[${i}]
                ${check_Referring}=    Evaluate    "${text_Referring}" in "${Referring}"
                Set Suite Variable    ${check_Referring}
                ${text_Medication}=    Get From List    ${list_Medication}    ${i}
                ${text_Medication}=    Get Text    ${text_Medication}
                Set Suite Variable    ${text_Medication}
                ${check_apmt}    Set Variable    ${True}
                BREAK                  
            END                               
        END   
        IF    ${check_apmt} == ${True} 
            BREAK
        END                            
        Sleep    15
        Wait Until Element Is Visible    xpath:/html/body/div[1]/div/div[4]/div[3]/div[2]/a[6]    10
        ${str}=    Get WebElement    xpath:/html/body/div[1]/div/div[4]/div[3]/div[2]/a[6]    #//*[@id="AppointmentList"]/div[3]/div[2]/a[6]  
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${str}
        Log To Console    check apmt(1):....................${check_apmt}
    END
    Log To Console    check apmt(2):..................... ${check_apmt}     
    Should Be Equal    ${check_apmt}    ${True}
    Close Browser    
Ledger View - msg displayed in apmt
    # Should Be Equal    ${text_view_HL7}    ${view_HL7}
    Set Suite Variable    ${text_Medication}
Ledger View - appointment time displayed in apmt
    Should Be Equal    ${text_Date_of_appointment}    ${Date_of_appointment}
    Should Be Equal    ${text_Time_of_appointment}    ${Time_of_appointment}
Ledger View - MRN displayed in apmt
    Should Be Equal    ${text_MRN}    ${MRN}
Ledger View - number of patient displayed in apmt
    Should Be Equal    ${text_Number_of_patient}    ${Number_of_patient}
Ledger View - DOB displayed in apmt
    Should Be Equal    ${text_DOB}    ${DOB}
Ledger View - service type displayed in apmt
    # Should Be Equal    ${Service_Type}    ${text_Service_Type}
    Set Suite Variable    ${text_Medication}
Ledget View - DX code displayed in apmt
    Should Be Equal    ${text_DX_Code}    ${DX_Code}
Ledger View - refer to (physician) displayed in apmt
    Should Be Equal    ${Refer_to}    ${text_Refer_to}
Ledger View - referring (physician) displayed in apmt
    # Should Be Equal    ${check_Referring}    ${True}
    Set Suite Variable    ${text_Medication}
Ledger View - medication displayed in apmt
    Should Be Equal    ${text_Medication}    ${Medication}


*** Keywords ***
Setup A

    Login To Fusebox
    Find Messege in HL7 Tool Page
    Find Patient in Patient Page  
    Go Update A Patient page
    Go Scheduled Appointments Tab
    Go Open Appointments Tab
    Go Calendar View Page
    #Go Ledger View Page
    Go Provider Orders Tab
    # Go Prior Authorizations


 
Go Update A Patient page
    Set Global Variable    ${right_MRN}
    ${element_Number_of_patient}=    Get WebElement     //table//tbody//tr[td[normalize-space(text())="${right_MRN}"]]//td[2]/a
    ${str_Number_of_patient}=    Get Text    ${element_Number_of_patient}
    #${element_Service_Type}=    Get WebElement    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[2]/div[3]/div[1]/div[3]
    #${str_Service_Type}=    Get Text    ${element_Service_Type}
    Set Suite Variable    ${str_Number_of_patient}
    #Set Suite Variable    ${str_Service_Type}
    Click Element    ${element_Number_of_patient}
    Title Should Be    Update Patient
    Element Should Contain    //*[@id="body"]/div/div[2]/div/h4    ${str_Number_of_patient}

Go Addresses Tab
    ${str_Adress_Tab}=    Get WebElement    //*[@id="Address"]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${str_Adress_Tab}
    Sleep    2
    Element Should Contain    //*[@id="AddressTabList"]/div[1]/div/h3    Addresses


Go Provider Orders Tab
    # ${bool_1}=    Run Keyword And Return Status    Get WebElement    ${element_Xpath_prior_Authorization} 
#Go PA page   
    ${element_Xpath_prior}=    Set Variable    //*[@id="PriorAuthorization"]
    ${str_Prior_authorization_Tab}=    Get WebElement    ${element_Xpath_prior}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${str_Prior_authorization_Tab}
    Wait Until Element Is Visible    //*[@id="PriorAuthorizationTabList"]/div[1]/div[1]/h2    10
    Sleep    2
    ${bool_1}=    Run Keyword And Return Status    Get Text    ${medication_Only}  
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True} 
            ${element_Xpath_prior_Authorization}    Set Variable    //div[@id="PriorAuthorizationTabList"]//tr[td[div[strong[normalize-space(text())="${medication_Only}"]]]][1]       
            ${str_Status_of_PA}=    Get Text    ${element_Xpath_prior_Authorization}//td[@data-column="4"]//div[@class="text-nowrap"][1]
            ${service_Type}=    Get Text    ${element_Xpath_prior_Authorization}//td[@data-column="5"]//div[@class="text-nowrap text-center"]
            ${code}=    Get Text    ${element_Xpath_prior_Authorization}//td[@data-column="5"]//div[@class="text-nowrap"][1]
            Set Global Variable    ${str_Status_of_PA}
            Set Global Variable    ${service_Type}
            ${a}    Create List
            ${str_Provider_order_Tab}=    Get WebElement    //*[@id="PhysicianOrder"]
            Execute Javascript    arguments[0].click();    ARGUMENTS    ${str_Provider_order_Tab}
            Wait Until Page Contains Element    //*[@id="PhysicianOrder"and @aria-expanded="true"]    20
            # ${medication_Only}=    Set Variable    Nucala
            ${element_Xpath}=    Set Variable    //div[@id="PhysicianOrderTabList"]//tr[td[div[strong[normalize-space(text())="${medication_Only}"]]]][last()]
            # ${bool}    Run Keyword And Return Status    Get WebElement    ${element_Xpath}
    #     IF    ${bool} == ${True}
            ${number_PO}=    Get Text    ${element_Xpath}//following-sibling::td[@data-column="5"]
            ${icd_ Code}=    Get Text    ${element_Xpath}//following-sibling::td[@data-column="7"]//div[@class="text-nowrap"][1]  
            # ${element_Dosage}=    Get WebElement    ${element_Xpath}//following-sibling::td[@data-column="3"]  
            Scroll Element Into View    ${element_Xpath}    
            Wait Until Element Is Visible    ${element_Xpath}    15
            Click Element    ${element_Xpath}
            Wait Until Element Is Visible    //div[@class="col-xs-6"]//*[@id="Weight"]
            Sleep    5
            ${expiration_Date_of_PO}=    Get Value    //*[@id="ExpirationDate"]
            ${str_Weight}=    Get Text    //div[@class="col-xs-6"]//*[@id="Weight"]    
            ${element_Dosage}=    Get Value   //*[@id="DosageAssigned"]
            # Append To List    ${a}    ${number_PO}    ${icd_ Code}    ${expiration_Date_of_PO}  
            ${title}=    Get Element Attribute    //*[@id="PatientInnerView"]/div[1]/div[1]/div[2]/div/button    title
            ${referring_Provider}=    Get Text    //*[@id="PatientInnerView"]/div[1]/div[1]/div[2]/div/button/span[1]
            ${refer_To _provider_In_po}=    Get Text    //*[@id="PatientInnerView"]/div[2]/div[2]/div
            Click Element    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]     
            Wait Until Element Is Not Visible    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]    10
            Click Element    //*[@id="Appointment"]
            Wait Until Element Is Visible    //div[@id="AppointmentTabList"]//div[@class="pager ImportListPager"]//div[@class="pager-total text-nowrap"]    15
            Set Global Variable    ${number_PO}
            Set Global Variable    ${icd_ Code}
            Set Global Variable    ${expiration_Date_of_PO}
            Set Global Variable    ${referring_Provider}
            Set Global Variable    ${element_Dosage}
            Set Global Variable    ${element_Xpath}
            Set Global Variable    ${str_Weight}
            Set Global Variable    ${refer_To _provider_In_po}
            Go Scheduled Appointments Tab
        #     Go Scheduled Appointments Tab
        #     Element Should Contain    ${element_PA}    PA: Assigned
        #     Element Should Contain    ${element_PO_link}    ${number_PO}
        #     Should Be Equal    ${element_DX_code}    ${icd_ Code}
        #     Element Should Contain    ${element_Referring_provider}    ${referring_Provider}
            # Should Be Equal    ${element_Dosage}    ${dosage_2}
        #     Go Open Appointments Tab
        #     Wait Until Element Is Visible    //*[@id="AppointmentItemTable"]/tbody/tr[1]/td/div    10
        #     Wait Until Element Is Visible    //div[@id="SubModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[@type="button"]    10
        #     Click Element    //div[@id="SubModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[@type="button"]
        #     Element Should Contain    ${element_Service_type}    ${service_Type}    ignore_case=True
        # #Primary Therapy
        #     Sleep    5
        #     Element Should Contain    //*[@id="Therapy"]    ${str_Of_dosage} 
        #     Element Should Contain    //*[@id="Therapy"]    ${number_PO} 
        #     Element Should Contain    //*[@id="Therapy"]    ${expiration_Date_of_PO}
        #     Element Should Contain    //*[@id="Therapy"]    ${medication_Only}
            
        #Primary Medication
            # Sleep    3
            # Element Should Contain    //div[@style="background-color: #337ab7; border-radius: 5px; padding: 7px;"]    ${str_Of_dosage} 
            # Element Should Contain    //div[@style="background-color: #337ab7; border-radius: 5px; padding: 7px;"]    ${medication_Only}
            # Element Should Contain    //*[@id="PrimaryMedicationBadge"]    1
            # Click Element    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]
            # Wait Until Element Is Not Visible    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]    10

        ELSE
            Go Scheduled Appointments Tab
            # Wait Until Element Is Visible    //div[@id="AppointmentTabList"]//div[@class="pager ImportListPager"]//div[@class="pager-total text-nowrap"]    10    
            # # Element Should Contain    ${element_PA}    PA: Not Assigned
            # # Element Should Not Contain    ${element_PA}    PO
            # # Element Should Contain    ${element_ICD_code}    N/A
            # # Element Should Contain    ${element_Service_type}    BUY AND BILL
            # Go Open Appointments Tab
            # Wait Until Element Is Visible    //*[@id="AppointmentItemTable"]/tbody/tr[1]/td/div    10
            # Sleep    10
            # ${pop_UP}=    Get WebElement    //div[@id="SubModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[@type="button"] 
            # ${bool_4}=    Run Keyword And Return Status    Get WebElement    ${pop_UP}    
            # IF    ${bool_4} == ${True} 
            #     Click Element    //div[@id="SubModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[@type="button"]
            # END
            # # Element Should Contain    //*[@id="Therapy"]    Unsaved Therapy
            # # Element Should Contain    //*[@id="AppointmentItemTable"]/tbody/tr[1]/td/div    No Primary Medications Added
            # Click Element    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]
            # Wait Until Element Is Not Visible    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]    10
        END    
    # Set Global Variable    ${a}
    # Run Keyword And Continue On Failure        Lists Should Be Equal    list1    list2
    # Run Keyword And Continue On Failure    SHould be string    1    2[1]



# Go Prior Authorizations
#     #Close Open Appointment
#     Click Element    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]
#     Wait Until Element Is Not Visible    //div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-header col-xs-12"]//div[@class="col-xs-1 text-right"]//*[@id="TopCloseBtn"]    20
#     ${element_Xpath_prior}=    Set Variable    //*[@id="PriorAuthorization"]
#     ${str_Prior_authorization_Tab}=    Get WebElement    ${element_Xpath_prior}
#     Execute Javascript    arguments[0].click();    ARGUMENTS    ${str_Prior_authorization_Tab}
#     Wait Until Element Is Visible    //*[@id="PriorAuthorizationTabList"]/div[1]/div[1]/h2    10
#     ${element_Xpath_prior_Authorization}    Set Variable    //div[@id="PriorAuthorizationTabList"]//tr[td[div[strong[normalize-space(text())="${medication_Only}"]]]][1]    
#     Sleep    2
#     ${str_Status_of_PA}=    Get Text    ${element_Xpath_prior_Authorization}//td[@data-column="4"]//div[@class="text-nowrap"][1]
#     ${service_Type}=    Get Text    ${element_Xpath_prior_Authorization}//td[@data-column="5"]//div[@class="text-nowrap text-center"]
#     ${code}=    Get Text    ${element_Xpath_prior_Authorization}//td[@data-column="5"]//div[@class="text-nowrap"][1]
#     Set Global Variable    ${str_Status_of_PA}
#     Set Global Variable    ${service_Type}
#     Element Should Contain    ${element_Service_type}    ${service_Type}    ignore_case=True
#     Go Open Appointments Tab
#     List Selection Should Be    //*[@id="AppointmentType"]    ${service_Type}
#     Element Should Contain    //*[@id="_CurrentAppointmentTab"]/div[5]/div[1]/a    ${code}

Go Scheduled Appointments Tab
#    Set Suite Variable    ${dict_Input}
     # Open Browser To Login Page
    # Login account        abc    Vbpo@12345    #Oanh    Oanh54321!
    # Go To    https://secure.fabricius-software.com/Patient/Edit?patientId=MzQ1NjU_&accountId=Mjg_
    # Set Global Variable    ${last_Processed}
    Click Element    //*[@id="Appointment"]            #Click Scheduled Appointment
    Wait Until Element Is Visible    //*[@id="AppointmentTabList"]/div[3]/div    60
    ${list_Vie_hl7_Button}=    Get WebElements    //tr[@class="accountRow"]//td[@class="col-xs-1"]//div[@class="text-center"]//span[contains(text(),'View HL7')]
        FOR    ${index}    ${i_View_hl7}    IN ENUMERATE    @{list_Vie_hl7_Button}
            Scroll Element Into View    //tr[@class="accountRow"][${index+1}]//div[span[contains(text(),'View HL7')]]//following-sibling::div[a[contains(text(),"View Changes ")]]
            Click Element    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="text-center"]//span[contains(text(),'View HL7')]
            Wait Until Element Is Visible    //div[@id="ModalPopup"]    10
            Sleep    5
            ${list_View_Deital}=    Get WebElements    //tr//td[@class="CenterAll"]//a[@class="btn btn-sm btn-default ViewTransactionBtn"]
            ${list_Create_Date}=    Get WebElements    //table[@class="table table-bordered"]//tbody//tr//td[@class="CenterAll"][1]
            ${list_Last_Processed}=    Get WebElements    //table[@class="table table-bordered"]//tbody//tr//td[@class="CenterAll"][2]            
            #${test}=    Get Element Count    //table[@class="table table-bordered"]//tbody//tr//td[@class="CenterAll"][1]   
            FOR    ${index_Last_Processed}    ${i_Last_Processed}    IN ENUMERATE   @{list_Last_Processed}
                ${str_index_Last_Processed}=    Convert To Integer    ${index_Last_Processed} 
                ${create_Date_str}=    Get Text    //table[@class="table table-bordered"]//tbody//tr[${index_Last_Processed+1+${str_index_Last_Processed}}]//td[@class="CenterAll"][1]
                ${str_Processed}=    Get Text    //table[@class="table table-bordered"]//tbody//tr[${index_Last_Processed+1+${str_index_Last_Processed}}]//td[@class="CenterAll"][2]    


                # ${str_Create_Date}=    Get Text    ${list_Create_Date}[${index_Last_Processed}]
                ${str_Create_Date}=    Convert Date    ${create_Date_str}    epoch    date_format=%m/%d/%Y at %H:%M %p           
                ${date}=    Convert Date    ${create_Date}    epoch    date_format=%m/%d/%Y %H:%M %p
                # ${date}=    Convert Date    3/24/2023 at 12:44 PM    epoch    date_format=%m/%d/%Y at %H:%M %p

                #Click Element    //table[@class="table table-bordered"]//tbody//tr//td[contains(text(),'${date_1}')]//following-sibling::td//a[text()='View Document ']    
                IF    ${str_Create_Date} >= ${date}
                    Click Element    //tr[${index_Last_Processed+1+${str_index_Last_Processed}}]//td[@class="CenterAll"]//a[@class="btn btn-sm btn-default ViewTransactionBtn"]
                    ${str_FileContent}    Get Text    //tr[@class="hl7documentViewer"]//td[@colspan="6"]//div[@class="Panel panel-info"]//div[@class="panel-body col-xs-12"]//*[@id="file_DocumentText"]
                    Log To Console    ${str_FileContent}
                    Should Be Equal As Strings     """${str_FileContent.strip()}"""    """${str_Input.strip()}"""                   
                END
            END
                Click Element    //body[@class="fullpage modal-open"]//div[@id="body"]//div[@class="container-fluid"]//div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[contains(@id,"CloseBtn")]
                Wait Until Page Does Not Contain Element    //body[@class="fullpage modal-open"]//div[@id="body"]//div[@class="container-fluid"]//div[@id="ModalPopup"]//div[@class="modal-dialog"]//div[@class="modal-content"]//div[@class="modal-footer"]//button[contains(@id,"CloseBtn")]    10                                                                                                    
        END
    ${element_MRN}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-12"]//div[@class="col-xs-6"]//div[@class="col-xs-7"]//strong
    Set Global Variable    ${element_MRN}
    ${element_String_number}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-12 text-left"]//div[@class="col-xs-4 text-left"]//strong[@style="text-decoration: underline;"]    
    Set Global Variable    ${element_String_number}
    ${element_Date_of_appointment}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="row text-center"]//strong[@class="DateOfServiceLabel"]   
    ${str_Date_of_appointment}=    Get Text    ${element_Date_of_appointment}
    Set Global Variable    ${element_Date_of_appointment}
    Set Global Variable    ${str_Date_of_appointment}
    ${element_Time_of_appointment}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="row text-center"][2]/strong
    ${str_Time_of_appointment}=    Get Text    ${element_Time_of_appointment}
    ${str_Time_of_appointment}=    Convert To Lower Case    ${str_Time_of_appointment}
    Set Global Variable    ${element_Time_of_appointment}
    Set Global Variable    ${str_Time_of_appointment}
    ${element_str_DOB}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-12"]//div[@class="col-xs-6"]//div[@class="col-xs-5"]//strong
    ${str_DOB}=    Get Text    ${element_str_DOB}
    Set Global Variable    ${element_str_DOB}
    Set Global Variable    ${str_DOB}
    ${element_str_Medication}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-4 ApptMedications"]//strong[@style="font-size: 24px;"]
    ${str_Medication}    Get Text    ${element_str_Medication}
    Set Global Variable    ${element_str_Medication}
    Set Global Variable    ${str_Medication}
    ${str_Status}=    Get Text    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="text-center"]//span[@class="badge appointmentStatusBadge"]
    Set Global Variable    ${str_Status}
    ${str_Appointment_id_APT}=    Get Text     //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="text-center"]//strong[@style="text-decoration: underline;"]
    Set Suite Variable    ${str_Appointment_id_APT}
    #Element Should Contain    //div[@id="AppointmentTabList"]//div[@class="pager ImportListPager"]//div[@class="pager-total text-nowrap"]    5
    ${dosage}=    Get Text    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-4 ApptMedications"]//strong[@style="font-size: 24px;"]
    Set Global Variable    ${dosage}
    ${str_Dosage}=    Split String    ${dosage}    separator= \- \
    Set Global Variable    ${str_Dosage}
    # ${bool_1}=    Run Keyword And Return Status    Get WebElement    ${element_Xpath_prior_Authorization} 
    ${bool_2}=    Run Keyword And Return Status    Get From List    ${str_Dosage}    -2
        IF    ${bool_2} == ${True}
            ${str_Medication}=    Get From List    ${str_Dosage}    -2
            ${str_Medication_only}=    Split String    ${str_Medication}
            ${medication_Only}=    Get From List    ${str_Medication_only}    -2    
            ${str_Of_dosage}=    Get From List    ${str_Dosage}    -1
            ${dosage_1}=    Split String    ${str_Of_dosage}    separator= \
            ${dosage_2}=    Get From List    ${dosage_1}    -2
            Set Global Variable    ${dosage_2}
            Set Global Variable    ${dosage}
            Set Global Variable    ${str_Dosage}
            Set Global Variable    ${str_Medication}
            Set Global Variable    ${str_Of_dosage}
            Set Global Variable    ${medication_Only}
            ${element_PO_link}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="col-xs-12 text-center"]//a[contains(text(),'PO')]
            Set Global Variable    ${element_PO_link}    
            Set Suite Variable    ${dict_Input}
            ${str_Medication_name_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[AIS-1][3]    2
            Should Contain    ${str_Medication_name_Input}    ${medication_Only}    ignore_case=${True}        
        ELSE
            Set Suite Variable    ${dict_Input}
            ${str_Medication_name_Input}=    PythonKeywords.Get Sub Field    ${dict_Input}[AIS-1][3]    2
            ${medication_1}=    Get Text    ${element_str_Medication}
            Should Contain    ${str_Medication_name_Input}    ${medication_1}    ignore_case=${True}
            Set Global Variable    ${medication_1}
        END
    
    ${list_Open_Appointment_Tab}=    Get WebElements    //tr[@class="accountRow"]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-2"]//div[@class="col-xs-11 col-xs-offset-1 AppointmentLedgerRows text-right"]//a[@class="ActiveCellProductSelection btn btn-sm btn-primary btn-block "]
    ${str_Open_Appointment_Tab}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-2"]//div[@class="col-xs-11 col-xs-offset-1 AppointmentLedgerRows text-right"]//a[@class="ActiveCellProductSelection btn btn-sm btn-primary btn-block "]  
    Set Global Variable    ${str_Open_Appointment_Tab}
    ${element_Service_type}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-12"]//div[@class="col-xs-6"]//div[@class="col-xs-12"]//strong
    Set Global Variable    ${element_Service_type}
    ${element_ICD_code}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-12"]//div[@class="col-xs-4"]//strong
    ${element_DX_code}=    Get Text    //tr[@class="accountRow"][${index+1}]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-12"]//div[@class="col-xs-4"]//strong
    Set Global Variable    ${element_DX_code}   
    Set Global Variable    ${element_ICD_code} 
    ${element_PA}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="col-xs-12 text-center"]//a[contains(text(),'PA')]
    Set Global Variable    ${element_PA}
    ${element_Referring_provider}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class=""]//div[@class="col-xs-12"]//div[@class="col-xs-3"]//div[@class="col-xs-12"]//select[@id="item_ReferringPhysicianID"]
    Set Global Variable    ${element_Referring_provider}
    ${element_Refer_to_Provider}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class=""]//div[@class="col-xs-12"]//div[@class="col-xs-3"]//div[@class="col-xs-12"]//select[@id="item_PhysicianId"]
    Set Global Variable    ${element_Refer_to_Provider}
    ${element_View_hl7}=    Get WebElement    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="text-center"]//span[contains(text(),'View HL7')]
    Set Global Variable    ${element_View_hl7}
    ${apt_ID}=    Get Text    //tr[@class="accountRow"][${index+1}]//td[@class="col-xs-1"]//div[@class="text-center"]//strong[@style="text-decoration: underline;"]
    Set Global Variable    ${apt_ID}

Go Open Appointments Tab
    Go Scheduled Appointments Tab
    Set Global Variable    ${str_Open_Appointment_Tab}
    #${str_Open_Appointment_Tab}=    Get WebElement    //tr[@class="accountRow"][3]//td[@style="border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-color: #333; border-width: thin;"]//div[@class="col-xs-2"]//div[@class="col-xs-11 col-xs-offset-1 AppointmentLedgerRows text-right"]//a[@class="ActiveCellProductSelection btn btn-sm btn-primary btn-block "]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${str_Open_Appointment_Tab}
    Sleep    5
    Element Should Contain    //*[@id="frm_AssignDosageToAppointment"]    Appointment Information 
        
            
    
Go Calendar View Page
    Go To    https://secure.fabricius-software.com/Appointment/Index?id=Ng__&vt=3
    Title Should Be    Appointment Ordering Ledger
    Wait Until Element Is Visible    //*[@id="appointmentViewsDropdown"]    timeout=60
    Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
    Input Text    //*[@id="StartDate"]    ${str_Date_of_appointment}        #Input Start date

    Press Keys    //*[@id="StartDate"]    RETURN

    Input Text    //*[@id="EndDate"]    ${str_Date_of_appointment}         #Input End Date

    Press Keys    //*[@id="EndDate"]    RETURN

    Click Element    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
    Input Text    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    100028    #Input Location
    # //ul[@role="listbox"]//li//a//span[text()='${LOCATION_MSG} ']

    Press Keys    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    RETURN
    Wait Until Page Contains Element    //div[contains(@id,"main-calendar-loading-div")]    100
    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5
    Sleep    10
    @{elements_list_time}=    Get WebElements    //*[@id="mainview_calendar"]/div[2]/div[3]/table/tbody/tr[3]/td[2]/div/div[*]/div[1]
    @{elements_list_title}=    Get WebElements    //*[@id="mainview_calendar"]/div[2]/div[3]/table/tbody/tr[3]/td[2]/div/div[*]/div[4]

    FOR    ${index_title}    ${i_title}    IN ENUMERATE    @{elements_list_title}
        ${str_title}=    Get Text    ${i_title}
        ${str_time}=    Get Text    ${elements_list_time}[${index_title}]
        IF    '''${str_title}''' == '''${str_Number_of_patient}'''
            Log To Console    ${str_title}
            ${str_time}=    Convert To Upper Case    ${str_time}
    
            Set Suite Variable    ${index_title}
            BREAK
        END
        Log To Console    ${index_title}
    END
    ${str_Time_of_appointment}=    Convert To Upper Case    ${str_Time_of_appointment}
    ${str_Time_of_appointment_1}=    Convert Date    ${str_Date_of_appointment} ${str_Time_of_appointment}    epoch    date_format=%m/%d/%Y %H:%M %p  
    ${str_time_1}=    Convert Date    ${str_Date_of_appointment} ${str_time}    epoch    date_format=%m/%d/%Y %H:%M %p
    Should Be Equal As Strings    ${str_Time_of_appointment_1}    ${str_time_1}
    #     FOR    ${index}    ${i_test}    IN ENUMERATE    @{test}
    #         ${list_ele_text}    Create List
    #         # //td[contains(@class,"ui-state-default wc-day-column wc-day-column")][Index cot]//div[@data-rel="calendarapptpopup"][index item]//div[text()]
    #         ${text_i_test}    Get WebElements    //div[@data-rel="calendarapptpopup"][${index+1}]//div    #[@class]
    #         FOR    ${i_text_i_test}    IN    @{text_i_test}
    #             ${ele_text}    Get Text    ${i_text_i_test}
    #             Append To List     ${list_ele_text}    ${ele_text}
    #         END
    #         ${Age}    Split String    ${list_ele_text}[4]    Age: \
    #         ${Status}    Split String    ${list_ele_text}[-1]    Status: \      
    #         ${Medication}    Split String    ${list_ele_text}[5]    Medication: \
    #         Set List Value    ${list_ele_text}    4    ${Age}[-1]
    #         Set List Value    ${list_ele_text}    5    ${Medication}[-1]
    #         Set List Value    ${list_ele_text}    -1    ${Status}[-1]
    #         Remove From List    ${list_ele_text}    1  
    #         Log To Console    ${list_ele_text}
    #         Append To List    ${list_final}    ${list_ele_text}
    #     END
    #     Log To Console    ${list_final}
    # List Should Contain Value    ${list_final}    ${list_So_sanh}


# Go Ledger View Page
#     Open Browser To Login Page
#     Login account        abc    Vbpo@12345    #Oanh    Oanh54321!
#     Go To    https://fusebox-portal-vn.azurewebsites.net/Patient/Edit?patientId=MTk2ODU5&accountId=Mjg_&active=appointment
#     Wait Until Element Contains    //*[@id="AppointmentTabList"]    Scheduled Appointments
#     ${str_Date_of_appointment}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[2]
#     #Log To Console    ${str_Date_of_appointment}
#     ${str_Time_of_appointment}=    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[3]
#     ${str_Time_of_appointment}=    Convert To Lower Case    ${str_Time_of_appointment}
#     #Log To Console    ${str_Time_of_appointment}
#     ${str_Apt_id}    Get Text    //*[@id="AppointmentTabList"]/table/tbody/tr[3]/td[1]/div[1]/strong
#     ${list_Apt_id}    Convert To List    ${str_Apt_id}
#     #Log To Console    ${str_Apt_id}
#     Go To    https://fusebox-portal-vn.azurewebsites.net/Appointment/Index?id=Ng__&vt=3
#     Title Should Be    Appointment Ordering Ledger
#     Wait Until Element Is Visible    //*[@id="appointmentViewsDropdown"]    timeout=60
#     Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
#     Input Text    //*[@id="StartDate"]   ${str_Date_of_appointment}        #Input Start date

#     Press Keys    //*[@id="StartDate"]    RETURN

#     Input Text    //*[@id="EndDate"]    ${str_Date_of_appointment}         #Input End Date

#     Press Keys    //*[@id="EndDate"]    RETURN

#     Click Element    //*[@id="body"]/div/div[2]/div/div/div[1]/div/button
#     Input Text    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    100028    #Input Location
#     # //ul[@role="listbox"]//li//a//span[text()='${LOCATION_MSG} ']

#     Press Keys    //*[@id="body"]/div/div[2]/div/div/div[1]/div/div/div/input    RETURN
#     Wait Until Page Contains Element    //div[contains(@id,"main-calendar-loading-div")]    100
#     Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5
#     #Wait Until Page Does Not Contain Element    //*[@class="fa fa-spinner fa-4x fa-spin"]    60
#     Click Element    //*[@id="appointmentViewsDropdown"]
#     Click Element    //*[@id="LedgerViewElement"]
#     ${list_Page}    Get WebElements    //*[@id="AppointmentList"]//div[@class="pager"]//div[@class="pager-navigation"]//a
#     ${list_Appointment}    Get WebElements    //tr[@class="accountRow"]
#     ${list_Appointment_final}    Create List
#     ${list_Page_final}    Create List
#         FOR    ${index_list_Page}    ${i_list_Page}    IN ENUMERATE    @{list_Page}
#             ${list_Page_temp}    Get WebElements    //*[@id="AppointmentList"]//div[@class="pager"]//div[@class="pager-navigation"]//a
#             Execute Javascript    arguments[0].click();    ARGUMENTS    ${list_Page_temp}[${index_list_Page}]
#             Log To Console    ${i_list_Page}
#             ${text_i_list_Page}    Get Text    ${i_list_Page}
#             Log To Console    ${text_i_list_Page}
        
#             FOR    ${index_list_Appointment}    ${i_list_Appointment}    IN ENUMERATE    @{list_Appointment}
#                 ${text_Apt_id}=    Get Text    //tr[@class="accountRow"][${index_list_Appointment+1}]//div[@class="text-center"]//strong[@style="text-decoration: underline;"]
#                 Append To List    ${list_Appointment_final}    ${text_Apt_id} 
#                 Log To Console    ${text_Apt_id}               
#             END
#             Append To List    ${list_Page_final}    ${i_list_Page}            
#         END
        
        
#     Log To Console    ${i_list_Page}
#     Log To Console    ${list_Appointment_final}
#     List Should Contain Value    ${list_Appointment_final}    ${str_Apt_id}

        



Find Patient in Patient Page
    Set Global Variable    ${dict_Input}
    Go To    https://secure.fabricius-software.com/Patient?accountId=Ng__
    Title Should Be    Patients
    # Wait Until Element Is Visible    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[4]    timeout=60
    Wait Until Element Is Visible    //*[@id="body"]/div/div[2]/div[1]/div/div/button
    Click Element    //*[@id="body"]/div/div[2]/div[1]/div/div/button
    Input Text    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input    ${LOCATION_MSG}
    Sleep    1
    Press Keys    //*[@id="body"]/div/div[2]/div[1]/div/div/div/div/input    RETURN
    Sleep    2
    Log To Console    ${dict_Input}[PID-1][18]
    Input Text    //*[@id="SearchValues"]    ${dict_Input}[PID-1][18]        #${dict_Input}[PID-1][18]
    Sleep    2
    Press Keys    //*[@id="SearchValues"]    RETURN
    Sleep    2
    Wait Until Element Is Not Visible    //*[@id="loading-indicator"]    timeout=90
    Sleep    20
    # Wait Until Element Contains    //*[@id="SearchValues"]    ${dict_Input}[PID-1][18]    15  
    Element Should Contain    //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[4]    ${dict_Input}[PID-1][18]        #${dict_Input}[PID-1][18]
    ${element_Number_of_patient}=    Get WebElement     //*[@id="PatientList"]/div[2]/table/tbody/tr[1]/td[2]/a
    ${str_Number_of_patient}=    Get Text    ${element_Number_of_patient}
    Set Suite Variable    ${str_Number_of_patient}


Find Messege in HL7 Tool Page
    # Set Suite Variable    ${date_Upload_Msg}
    # Set Suite Variable    ${str_Input}
    # ${bl_Exit}=    Set Variable    ${False}
    # WHILE    ${bl_Exit} == ${False}
    Go To    https://secure.fabricius-software.com/HL7Tools/Index/Ng__
    Title Should Be    HL7 Tools
    Select From List By Label    //select[contains(@id,"HL7FileTypeId")]    ${FILE_TYPE_MSG}  
    Press Keys    //select[contains(@id,"HL7FileTypeId")]    RETURN
    Sleep    2
    Select From List By Label    //select[contains(@id,"HL7SenderId")]    ${SENDER_MSG}
    Press Keys    //select[contains(@id,"HL7SenderId")]    RETURN
    Sleep    2
    ${str_Datetime_Now}=    PythonKeywords.Get Time Now
    ${test}=    Split String    ${str_Datetime_Now}
    ${test_1}    Get From List    ${test}    0
    ${test_2}=    Set Variable    03/27/2023
    # ${date_Upload_Msg}=    Convert Date    ${str_Datetime_Now}    epoch    date_format=%m/%d/%Y %H:%M %p
    Input Text    //*[@id="StartDate"]    ${test_2}

    Press Keys    //*[@id="StartDate"]    RETURN
    
    Sleep    15
    Wait Until Element Is Visible    //*[@id="MailboxList"]/table/tbody/tr[1]/td[7]/a    30
    ${last_Processed}=    Get Text    //tr[1]//td[@class="text-center"][5]/span
    ${create_Date}=    Get Text    //tr[1]//td[@class="text-center"][4]/span
    ${last_Processed_date}=    Replace String    ${last_Processed}    search_for=:    replace_with=_\
    ${last_Processed_date}=    Replace String    ${last_Processed_date}    search_for= \    replace_with=_\
    ${create}=    Replace String    ${create_Date}    search_for=:    replace_with=_\    
    ${create}=    Replace String    ${create}    search_for=:    replace_with=_\
    ${view_Details_latest}=    Get WebElement    //tr[1]//td[@class="text-center"]//a[@class="btn btn-sm btn-success"]
    Click Element    ${view_Details_latest}
    Wait Until Element Is Visible    //textarea[@class="form-control"]    10
    ${message_content}=    Get Text    //textarea[@class="form-control"]  
    ${str_Datetime_Now}=    PythonKeywords.Get Time Now
    ${str_Datetime_Now}    Convert To String    ${str_Datetime_Now}
    Create File    ${create}.txt    ${message_content}
    Set Global Variable    ${last_Processed}
    Set Global Variable    ${create_Date}
    ${dict_Input}=    PythonKeywords.Read MSG    ${create}.txt    
        
    ${type}    Evaluate    type($dict_Input)
    Set Suite Variable    ${dict_Input}
        
    ${str_Input}=    PythonKeywords.Read Txt    ${create}.txt

    Set Suite Variable    ${str_Input}
        ##############new line added
    ${view_HL7}    Set Variable    ${message_content}
    Set Suite Variable    ${view_HL7}
    Set Global Variable    ${message_content}








        

Check Messege in View HL7
    Set Suite Variable    ${date_Upload_Msg}
    Set Suite Variable    ${str_Input}
    Sleep    2
    @{list_View_Deital}=    Get WebElements    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[*]/td[6]/a[1]
    @{list_Create_Date}=    Get WebElements    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[*]/td[2]
    @{list_Last_Processed}=    Get WebElements    //*[@id="frm_RelatedHL7DetailModal"]/table/tbody/tr[*]/td[3]

    ${str_Create_Date}=    Get Text   ${list_Create_Date}[-1]

    ${date_Create_Date}=    Convert Date    ${str_Create_Date}    epoch    date_format=%m/%d/%Y at %H:%M %p

    IF   ${date_Create_Date} >= ${date_Upload_Msg}

        Wait Until Element Is Visible    ${list_View_Deital}[-1]
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${list_View_Deital}[-1]
        Sleep    20
        
        ${element_FileContent}=    Get WebElement    //*[@id="file_DocumentText"]
        ${str_FileContent}=    Get Element Attribute    ${element_FileContent}    value

        Should Be Equal As Strings     """${str_FileContent.strip()}"""    """${str_Input.strip()}"""

        @{element_Button_Close}=    Get WebElements    //*[@id="CloseBtn"]
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${element_Button_Close}[1]
        Sleep    1

    END







Login To Fusebox
    Open Browser To Login Page
    Login account        Anh Bui    Anhbui@011607    #Oanh    Oanh54321!

Open Browser To Login Page
    # Open Browser    ${LOGIN URL}    ${BROWSER}    executable_path=C:/Users/nguye/Desktop/Test_script/chromedriver.exe    alias=BrowserA	
    # Open Browser    https://www.google.com.vn/?hl=vi    ${BROWSER}    executable_path=C:/Users/nguye/Desktop/Test_script/chromedriver.exe    alias=BrowserB	
    # &{aliases}	Get Browser Aliases		# &{aliases} = { BrowserA=1|BrowserB=2 }
    # Log To Console	${aliases.BrowserA}		# logs 1
    # FOR	${alias}	IN	@{aliases}
    #     Log To Console	${alias}	# logs BrowserA and BrowserB
    # END
    Open Browser    ${LOGIN URL}    ${BROWSER}    executable_path=C:/Users/nguye/Desktop/Test_script/chromedriver.exe    alias=BrowserFusebox
    Maximize Browser Window
    Title Should Be    Log In

Login Account
    [Arguments]    ${username}    ${password}
    Input Text    //*[@id="UserName"]    ${username}
    Input Text    //*[@id="Password"]    ${password}
    Click Button    //*[@id="frm_Login"]/input[2]
    Title Should Be    Home


# Dành cho việc chạy multi data *** Settings ***
# Library        DynamicTestLibrary
# Suite Setup    Generate Test Matrix

# Dành cho việc chạy multi data *** Keywords ***
# Generate Test Matrix
#     @{list_file}=   OperatingSystem.List Files In Directory     ${PATH_FOLDER_SIU}
#     ${test scenarios}=    Create List    Put File To SFTP
#     DynamicTestLibrary.Add Test Matrix    ${list_file}    ${test scenarios}

# Dành cho việc chạy multi data *** Test Cases ***
# Placeholder test
#     [Documentation]    Placeholder test to prevent empty suite error. It will be removed from execution during the run.
#     No Operation