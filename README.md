# BacenPowerBIConnector
This is a PowerBI Custom Connector that enables access to Bacen (Banco Central do Brasil) datasets. Currently, VAT tables are available.
This document provides instructions on how to use and set up a Power BI Custom Connector (.mez file) in Power BI. The steps below will guide you through enabling 3rd-party connectors.

**Prerequisites**
- Power BI Desktop.
- A .mez file (Power BI Custom Connector).

**Step-by-step Instructions**

Step 1: Enabling Third-Party Connectors
1. Open Power BI Desktop.
2. Click on "File" at the top left corner.
3. From the dropdown, navigate to "Options and settings" -> "Options".
4. In the Options window, navigate to the "Security" tab found in the left pane.
5. Under "Data Extensions", select the option "Allow any extension to load without validation or warning".
6. Click "OK" to save the changes.

_Note: This will allow Power BI to load third-party connectors.

**Step 2: Setting the Default Browser**
Configure Power BI to use your system's default web browser for authentication when using custom connectors. 

1. Open Power BI Desktop.
2. Click on "File" at the top left corner.
3. From the dropdown, navigate to "Options and settings" -> "Options".
4. In the Options window, navigate to the "Security" tab found in the left pane.
5. Under "Authentication Browser", select the option "Use my default web browser".
6. Click "OK" to save the changes.

_Note: The steps may slightly vary depending on the operating system._

**Step 3: Saving the .mez File**
1. Navigate to the following directory where Power BI Desktop is installed:

   For Windows, it's typically: “Documents/Power BI Desktop/Custom Connectors”.

2. If the “Custom Connectors” folder does not exist, please create it.
3. Download the "BacenConnector.mez" file found in this repository, and copy it into the “Custom Connectors” directory.

_Note: If Power BI Desktop was open during this process, please restart it so it can detect the new custom connector.

**Step 4: Accessing the Custom Connector**
1. Open Power BI Desktop.
2. Click on "Get Data" found in the Home ribbon.
3. From the dropdown, select "More".
4. In the "Get Data" window, navigate to the "Other" category.
5. Here you should see your Custom Connector listed by the name of the “.mez” file. If not, verify that you've followed the previous steps correctly.

_Note: If prompted, enter your credentials to authenticate the connector. 

**Conclusion**
Now you're ready to use your Custom Connector in Power BI Desktop. Remember that third-party connectors are not inherently trusted by Power BI, and you should only use connectors from sources you trust.

**Troubleshooting**
If you encounter issues, verify that you've followed all the steps correctly. If the problem persists, reach out to support@bell-finance.com.br.
