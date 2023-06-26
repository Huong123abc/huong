*** Settings ***
Documentation       Template robot main suite.

Library             Collections
Library             MyLibrary
Resource            keywords.robot
Variables           variables.py
Library             RPA.Browser.Selenium
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
Library    OperatingSystem

*** Tasks ***
Open the robot order website  
    Download file csv
    Set Global Variable    ${order}
    Open Browser  
    Create Folder
    FOR    ${row}    IN    @{order}   
        Log To Console    ${row}[Head] 
        Order another 
        Fill the form    ${row}
        Click Preview
        Capture robot                                          
        Save robot in PDF file    ${row}
    END
        Create zip
        
*** Keyword ***
Create zip
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    D:/HuongHNU/Robot${/}PDF_file    pdf.zip 
                 
Check file exist
    File Should Exist    /HuongHNU/Robot/orders.csv      
Fill the form    
    [Arguments]    ${row}    
    Set Global Variable    ${row}
    Wait Until Element Is Visible    //select[@id="head"]    30
    Select From List By Value    //select[@id="head"]    ${row}[Head]
    Click Element    //input[@name="body" and @value='${row}[Body]' ]    
    Input Text    //div[@class="form-group"]//input[@type="number"]    ${row}[Legs]      
    Input Text    //*[@id="address"]    ${row}[Address]
    Click Element    //*[@id="preview"]
    Click Element    //*[@id="order"]

Save robot in PDF file
    [Arguments]    ${row}
    Open Pdf    D:/HuongHNU/Robot/${row}[Order number]   
    Add Watermark Image To Pdf    ${row}[Order number].image    D:/HuongHNU/Robot/${row}[Order number]   
    Copy File    D:/HuongHNU/Robot/${row}[Order number]    D:/HuongHNU/Robot/PDF_file/${row}[Order number]

Download file csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}  
    ${order}=    Read table from CSV    /HuongHNU/Robot/orders.csv   
    Log To Console    ${order}
    Set Global Variable    ${order}

Open Browser
    Open Chrome Browser    https://robotsparebinindustries.com/#/
    Click Element    //li[@class="nav-item"]//a[contains(text(),'Order your robot!')]

Create Folder
    Create Directory    PDF_file    overwrite=${True}

Order another 
    ${bool}=    Run Keyword And Return Status    Page Should Contain Element    //*[@id="order-another"]
            IF    ${bool} == ${True}
                Click Element    //*[@id="order-another"]
                Click Element    //button[@class="btn btn-warning"]
            ELSE      
                Click Element    //button[@class="btn btn-warning"]              
                Click Element    //li[@class="nav-item"]//a[contains(text(),'Order your robot!')]
            END

Click Preview
    WHILE    True
            ${bool_1}=    Run Keyword And Ignore Error    Click Element    //*[@id="order"]
            ${bool}=    Run Keyword And Return Status    Wait Until Element Is Visible    //*[@id="receipt"]
            IF    ${bool} == ${True}
                Exit For Loop                            
            END                    
        END

Capture robot
    Set Global Variable    ${row}
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]
    ${image_1}=    Screenshot    //*[@id="robot-preview-image"]    filename=${row}[Order number].image
    ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML       
    ${pdf}=    Html To Pdf    ${order_receipt_html}    ${row}[Order number]
        # Sleep    10
        # ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML       
        # ${pdf}=    Html To Pdf    ${order_receipt_html}    ${row}[Head]   
        # Open Pdf    D:/HuongHNU/Robot/${row}[Head]   
        # Add Watermark Image To Pdf    ${row}[Head].image    D:/HuongHNU/Robot/${row}[Head]   
        # Copy File    D:/HuongHNU/Robot/${row}[Head]    D:/HuongHNU/Robot/PDF_file/${row}[Head]
        # ${bool}=    Run Keyword And Return Status    Page Should not Contain Element    //*[@id="receipt"]   
            # END            
            # IF    ${bool} == ${False}
            #     Click Element    //*[@id="order"]
            #     ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML       
            #     # ${pdf}=    Html To Pdf    ${order_receipt_html}    ${row}[Head]   
            #     # Open Pdf    D:/HuongHNU/Robot/${row}[Head]        
            #     # Add Watermark Image To Pdf    ${row}[Head].image    D:/HuongHNU/Robot/${row}[Head]
            #     # Copy File    D:/HuongHNU/Robot/${row}[Head]    D:/HuongHNU/Robot/PDF_file/${row}[Head]
            # ELSE
            #     ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML       
            #     # ${pdf}=    Html To Pdf    ${order_receipt_html}    ${row}[Head]  
            #     # Open Pdf    D:/HuongHNU/Robot/${row}[Head]   
            #     # Add Watermark Image To Pdf    ${row}[Head].image    D:/HuongHNU/Robot/${row}[Head]   
            #     # Copy File    D:/HuongHNU/Robot/${row}[Head]    D:/HuongHNU/Robot/PDF_file/${row}[Head]
                
            # END
        
        # ${file}=    Create List    D:/HuongHNU/Robot${/}${row}[Head]  
        # Add Files To Pdf    ${file}    D:/HuongHNU/Robot/PDF_file  
        # # Add To Archive    ${file}    D:/HuongHNU/Robot/PDF_file
    # Click Element     //select[@id="head"]//option[@value="1"]
    # Click Element     //div[@class="radio form-check"]//label[@for="id-body-1"]//input[@class="form-check-input"]
    # Input Text     //div[@class="form-group"]//input[@type="number"]    3
    # Input Text    //*[@id="address"]    123 Canada
    # Click Element    //*[@id="order"]
    
   
