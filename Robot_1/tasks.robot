*** Settings ***
Documentation       Template robot main suite.

Library             Collections
Library             MyLibrary
Resource            keywords.robot
Variables           variables.py
Library             RPA.Browser.Selenium
Library    RPA.Smartsheet
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.FileSystem
Library    RPA.Tables
Library    RPA.Excel.Application
Library    RPA.Robocorp.WorkItems
Library    RPA.PDF
Library    RPA.Email.Exchange
Library    RPA.Desktop
Library    RPA.Archive

*** Tasks ***
Open the robot order website
    # Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}  
    ${order}=    Read table from CSV    D:/HuongHNU/Robot/orders.csv   
    Log To Console    ${order}  
    Create Directory    D:/HuongHNU/Robot    overwrite=${True}          
    
    FOR    ${row}    IN    @{order}   
        Log To Console    ${row}[Head]  
        Open Chrome Browser    https://robotsparebinindustries.com/#/ 
        Click Element    //li[@class="nav-item"]//a[contains(text(),'Order your robot!')]
        Click Element    //button[@class="btn btn-warning"]
        Wait Until Element Is Visible    //select[@id="head"]
        Select From List By Value    //select[@id="head"]    ${row}[Head]
        Click Element    //input[@name="body" and @value='${row}[Body]' ]    
        Input Text    //div[@class="form-group"]//input[@type="number"]    ${row}[Legs]      
        Input Text    //*[@id="address"]    ${row}[Address]
        Click Element    //*[@id="preview"]
        Sleep    10
        ${image}=    Take Screenshot    
        ${image_1}=    Screenshot    //*[@id="robot-preview-image"]
        Click Element    //*[@id="order"]    
        Wait Until Element Is Visible    //*[@id="receipt"]    10
        ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML       
        ${pdf}=    Html To Pdf    ${order_receipt_html}    ${row}[Head]   
        Open Pdf    D:/HuongHNU/Robot/${row}[Head]        
        Add Watermark Image To Pdf    ${image_1}    D:/HuongHNU/Robot/${row}[Head]
        #Archive Folder With Zip    D:/HuongHNU/Robot    D:/HuongHNU/Robot/${row}[Head]
        Copy File    D:/HuongHNU/Robot/${row}[Head]    D:/HuongHNU/Robot/PDF_file/${row}[Head]
        # ${file}=    Create List    D:/HuongHNU/Robot${/}${row}[Head]  
        # Add Files To Pdf    ${file}    D:/HuongHNU/Robot/PDF_file  
        # # Add To Archive    ${file}    D:/HuongHNU/Robot/PDF_file
                         
        
    END
    Sleep    10
Create zip
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    D:/HuongHNU/Robot${/}PDF_file    pdf.zip      
   
# Create Zip from PDF Files
    # ${zip_file_name}=    Set Variable    D:/HuongHNU/Robot/PDFs.zip
    # Archive Folder With Zip    ${zip_file_name}    D:/HuongHNU/Robot/${row}[Head]
        


*** Keyword ***                       
Fill the form    
    [Arguments]    ${row}    
    Wait Until Element Is Visible    //select[@id="head"]
    Select From List By Value    //select[@id="head"]    ${row}[Head]
    Click Element    //input[@name="body" and @value='${row}[Body]' ]    
    Input Text    //div[@class="form-group"]//input[@type="number"]    ${row}[Legs]      
    Input Text    //*[@id="address"]    ${row}[Address]
    Click Element    //*[@id="preview"]
    Click Element    //*[@id="order"]
    Sleep    10

    # Click Element     //select[@id="head"]//option[@value="1"]
    # Click Element     //div[@class="radio form-check"]//label[@for="id-body-1"]//input[@class="form-check-input"]
    # Input Text     //div[@class="form-group"]//input[@type="number"]    3
    # Input Text    //*[@id="address"]    123 Canada
    # Click Element    //*[@id="order"]
    
   
