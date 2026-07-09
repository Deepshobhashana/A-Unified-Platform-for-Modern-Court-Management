CREATE SCHEMA court_management;
SET search_path TO court_management;

CREATE TABLE "User" (
    User_ID       INT           NOT NULL,
    Name          VARCHAR(100)  NOT NULL,
    Nationality   VARCHAR(60)   NOT NULL,
    DOB           DATE          NOT NULL,
    Password      VARCHAR(255)  NOT NULL,
    CONSTRAINT PK_User PRIMARY KEY (User_ID)
);

CREATE TABLE User_email (
    User_ID   INT           NOT NULL,
    Email     VARCHAR(254)  NOT NULL,
    CONSTRAINT PK_User_email PRIMARY KEY (User_ID, Email),
    CONSTRAINT FK_User_email_User FOREIGN KEY (User_ID) REFERENCES "User"(User_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE User_phone_number (
    User_ID       INT          NOT NULL,
    Phone_number  CHAR(10)     NOT NULL,
    CONSTRAINT PK_User_phone PRIMARY KEY (User_ID, Phone_number),
    CONSTRAINT FK_User_phone_User FOREIGN KEY (User_ID) REFERENCES "User"(User_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Judge (
    Judge_ID            INT          NOT NULL,
    User_ID             INT          NOT NULL,
    Working_status      VARCHAR(20)  NOT NULL CHECK (Working_status IN ('Active', 'Retired', 'Suspended')),
    Practising_since    DATE         NOT NULL,
    Working_here_since  DATE         NOT NULL,
    CONSTRAINT PK_Judge PRIMARY KEY (Judge_ID),
    CONSTRAINT UQ_Judge_Judge_ID UNIQUE (Judge_ID),
    CONSTRAINT UQ_Judge_User_ID  UNIQUE (User_ID),
    CONSTRAINT FK_Judge_User FOREIGN KEY (User_ID) REFERENCES "User"(User_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Judge_specialisation (
    Judge_ID        INT           NOT NULL,
    Specialisation  VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_Judge_spec PRIMARY KEY (Judge_ID, Specialisation),
    CONSTRAINT FK_Judge_spec_Judge FOREIGN KEY (Judge_ID) REFERENCES Judge(Judge_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Lawyer (
    Bar_council_number  VARCHAR(20)  NOT NULL,
    User_ID             INT          NOT NULL,
    Firm                VARCHAR(150)     NULL,
    Working_status      VARCHAR(20)  NOT NULL CHECK (Working_status IN ('Active', 'Inactive', 'Suspended', 'Retired')),
    CONSTRAINT PK_Lawyer PRIMARY KEY (Bar_council_number),
    CONSTRAINT UQ_Lawyer_Bar_council_number UNIQUE (Bar_council_number),
    CONSTRAINT UQ_Lawyer_User_ID UNIQUE (User_ID),
    CONSTRAINT FK_Lawyer_User FOREIGN KEY (User_ID) REFERENCES "User"(User_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Lawyer_specialisation (
    Bar_council_number  VARCHAR(20)   NOT NULL,
    Specialisation      VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_Lawyer_spec PRIMARY KEY (Bar_council_number, Specialisation),
    CONSTRAINT FK_Lawyer_spec_Lawyer FOREIGN KEY (Bar_council_number) REFERENCES Lawyer(Bar_council_number) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Admin (
    Admin_ID            INT           NOT NULL,
    User_ID             INT           NOT NULL,
    Post                VARCHAR(100)  NOT NULL,
    Working_here_since  DATE          NOT NULL,
    CONSTRAINT PK_Admin PRIMARY KEY (Admin_ID),
    CONSTRAINT UQ_Admin_Admin_ID UNIQUE (Admin_ID),
    CONSTRAINT UQ_Admin_User_ID  UNIQUE (User_ID),
    CONSTRAINT FK_Admin_User FOREIGN KEY (User_ID) REFERENCES "User"(User_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Litigant (
    Litigant_ID    INT          NOT NULL,
    User_ID        INT          NOT NULL,
    Type           VARCHAR(30)  NOT NULL CHECK (Type IN ('Individual', 'Organisation', 'Government')),
    Government_ID  VARCHAR(50)  NOT NULL,
    ID_number      VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Litigant PRIMARY KEY (Litigant_ID),
    CONSTRAINT UQ_Litigant_Litigant_ID UNIQUE (Litigant_ID),
    CONSTRAINT UQ_Litigant_User_ID     UNIQUE (User_ID),
    CONSTRAINT FK_Litigant_User FOREIGN KEY (User_ID) REFERENCES "User"(User_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Cause_list (
    List_ID           INT          NOT NULL,
    Courtroom_number  VARCHAR(10)  NOT NULL,
    Date              DATE         NOT NULL,
    Time              TIME         NOT NULL,
    CONSTRAINT PK_Cause_list PRIMARY KEY (List_ID)
);

CREATE TABLE "Case" (
    Case_ID         INT           NOT NULL,
    CNR             CHAR(16)      NOT NULL,
    Case_title      VARCHAR(255)  NOT NULL,
    Case_type       VARCHAR(50)   NOT NULL CHECK (Case_type IN ('Civil', 'Criminal', 'PIL', 'Writ', 'Arbitration', 'Matrimonial', 'Land Acquisition', 'Labour', 'Tax', 'Revenue', 'Commercial')),
    Current_status  VARCHAR(30)   NOT NULL CHECK (Current_status IN ('Pending', 'Active', 'Disposed', 'Stayed', 'Transferred', 'Withdrawn', 'Converted')),
    Description     TEXT          NOT NULL,
    Filing_date     DATE          NOT NULL,
    CONSTRAINT PK_Case PRIMARY KEY (Case_ID),
    CONSTRAINT UQ_Case_CNR UNIQUE (CNR)
);

CREATE TABLE Case_judges (
    Case_ID   INT  NOT NULL,
    Judge_ID  INT  NOT NULL,
    CONSTRAINT PK_Case_judges PRIMARY KEY (Case_ID, Judge_ID),
    CONSTRAINT FK_Case_judges_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Case_judges_Judge FOREIGN KEY (Judge_ID) REFERENCES Judge(Judge_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Case_litigants (
    Case_ID      INT  NOT NULL,
    Litigant_ID  INT  NOT NULL,
    CONSTRAINT PK_Case_litigants PRIMARY KEY (Case_ID, Litigant_ID),
    CONSTRAINT FK_Case_litigants_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Case_litigants_Litigant FOREIGN KEY (Litigant_ID) REFERENCES Litigant(Litigant_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Case_lawyers (
    Case_ID             INT          NOT NULL,
    Bar_council_number  VARCHAR(20)  NOT NULL,
    Type                VARCHAR(30)  NOT NULL CHECK (Type IN ('Petitioner', 'Respondent', 'Amicus Curiae', 'Intervener')),
    CONSTRAINT PK_Case_lawyers PRIMARY KEY (Case_ID, Bar_council_number),
    CONSTRAINT FK_Case_lawyers_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Case_lawyers_Lawyer FOREIGN KEY (Bar_council_number) REFERENCES Lawyer(Bar_council_number) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Case_history (
    Case_ID     INT          NOT NULL,
    Court_ID    VARCHAR(30)  NOT NULL,
    Date        DATE         NOT NULL,
    Court_type  VARCHAR(50)  NOT NULL CHECK (Court_type IN ('Supreme Court', 'High Court', 'District Court', 'Sessions Court', 'Magistrate Court', 'Tribunal', 'Family Court', 'Labour Court', 'Consumer Forum', 'CBI Court', 'POCSO Court')),
    Verdict     TEXT         NOT NULL,
    CONSTRAINT PK_Case_history PRIMARY KEY (Case_ID, Court_ID, Date),
    CONSTRAINT FK_Case_history_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Interlocutory_applications (
    IA_ID             INT           NOT NULL,
    Case_ID           INT           NOT NULL,
    Application_type  VARCHAR(50)   NOT NULL CHECK (Application_type IN ('Stay', 'Injunction', 'Bail', 'Anticipatory Bail', 'Maintenance', 'Attachment', 'Contempt', 'Other')),
    Date              DATE          NOT NULL,
    Status            VARCHAR(20)   NOT NULL CHECK (Status IN ('Pending', 'Granted', 'Rejected', 'Withdrawn')),
    CONSTRAINT PK_IA PRIMARY KEY (IA_ID),
    CONSTRAINT FK_IA_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Payment (
    Case_ID        INT            NOT NULL,
    Payment_number INT            NOT NULL,
    Purpose        VARCHAR(100)   NOT NULL,
    Payer_name     VARCHAR(150)   NOT NULL,
    Amount         DECIMAL(15,2)  NOT NULL CHECK (Amount > 0),
    Method         VARCHAR(20)    NOT NULL CHECK (Method IN ('Cash', 'Cheque', 'DD', 'NEFT', 'RTGS', 'UPI')),
    Date           DATE           NOT NULL,
    Status         VARCHAR(20)    NOT NULL CHECK (Status IN ('Paid', 'Pending', 'Failed', 'Refunded')),
    CONSTRAINT PK_Payment PRIMARY KEY (Case_ID, Payment_number),
    CONSTRAINT FK_Payment_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE FIR (
    FIR_number        VARCHAR(30)   NOT NULL,
    Case_ID           INT           NOT NULL,
    Police_station    VARCHAR(150)  NOT NULL,
    District          VARCHAR(100)  NOT NULL,
    Date_of_filing    DATE          NOT NULL,
    Sections_invoked  VARCHAR(255)  NOT NULL,
    Accused_name      VARCHAR(150)  NOT NULL,
    Complainant_name  VARCHAR(150)  NOT NULL,
    CONSTRAINT PK_FIR PRIMARY KEY (FIR_number),
    CONSTRAINT UQ_FIR_number UNIQUE (FIR_number),
    CONSTRAINT FK_FIR_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Witness (
    Witness_ID    INT          NOT NULL,
    Witness_type  VARCHAR(30)  NOT NULL CHECK (Witness_type IN ('Prosecution', 'Defence', 'Expert', 'Character', 'Court')),
    Name          VARCHAR(100) NOT NULL,
    Gender        VARCHAR(10)  NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    Address       TEXT         NOT NULL,
    CONSTRAINT PK_Witness PRIMARY KEY (Witness_ID)
);

CREATE TABLE Witness_phone_number (
    Witness_ID    INT       NOT NULL,
    Phone_number  CHAR(10)  NOT NULL,
    CONSTRAINT PK_Witness_phone PRIMARY KEY (Witness_ID, Phone_number),
    CONSTRAINT FK_Witness_phone_Witness FOREIGN KEY (Witness_ID) REFERENCES Witness(Witness_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Witness_email (
    Witness_ID  INT           NOT NULL,
    Email       VARCHAR(254)  NOT NULL,
    CONSTRAINT PK_Witness_email PRIMARY KEY (Witness_ID, Email),
    CONSTRAINT FK_Witness_email_Witness FOREIGN KEY (Witness_ID) REFERENCES Witness(Witness_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Hearing (
    Hearing_ID          INT           NOT NULL,
    Case_ID             INT           NOT NULL,
    Purpose             VARCHAR(100)  NOT NULL CHECK (Purpose IN ('Arguments', 'Evidence', 'Judgment', 'Framing of Charges', 'Cross Examination', 'Bail Hearing', 'Preliminary Hearing', 'Final Hearing')),
    List_ID             INT           NOT NULL,
    Judge_ID            INT           NOT NULL,
    Prosecutor_ID       VARCHAR(20)   NOT NULL,
    Defense_lawyer_ID   VARCHAR(20)   NOT NULL,
    Verdict             TEXT          NOT NULL,
    Next_date           DATE              NULL,
    CONSTRAINT PK_Hearing PRIMARY KEY (Hearing_ID),
    CONSTRAINT UQ_Hearing_ID UNIQUE (Hearing_ID),
    CONSTRAINT FK_Hearing_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Hearing_Cause_list FOREIGN KEY (List_ID) REFERENCES Cause_list(List_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Hearing_Judge FOREIGN KEY (Judge_ID) REFERENCES Judge(Judge_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Hearing_Prosecutor FOREIGN KEY (Prosecutor_ID) REFERENCES Lawyer(Bar_council_number) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Hearing_Defense FOREIGN KEY (Defense_lawyer_ID) REFERENCES Lawyer(Bar_council_number) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Has_witness (
    Hearing_ID  INT  NOT NULL,
    Witness_ID  INT  NOT NULL,
    CONSTRAINT PK_Has_witness PRIMARY KEY (Hearing_ID, Witness_ID),
    CONSTRAINT FK_Has_witness_Hearing FOREIGN KEY (Hearing_ID) REFERENCES Hearing(Hearing_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Has_witness_Witness FOREIGN KEY (Witness_ID) REFERENCES Witness(Witness_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Evidence (
    Evidence_ID   INT          NOT NULL,
    Case_ID       INT          NOT NULL,
    Submitted_by  VARCHAR(20)  NOT NULL,
    Uploaded_by   INT          NOT NULL,
    Type          VARCHAR(50)  NOT NULL CHECK (Type IN ('Document', 'Physical', 'Digital', 'Forensic', 'Witness Statement', 'CCTV')),
    Address       TEXT         NOT NULL,
    Submit_date   DATE         NOT NULL,
    CONSTRAINT PK_Evidence PRIMARY KEY (Evidence_ID),
    CONSTRAINT FK_Evidence_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Evidence_Submitted FOREIGN KEY (Submitted_by) REFERENCES Lawyer(Bar_council_number) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Evidence_Uploaded FOREIGN KEY (Uploaded_by) REFERENCES Admin(Admin_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Case_document (
    Document_ID       INT           NOT NULL,
    Case_ID           INT           NOT NULL,
    Hearing_ID        INT           NOT NULL,
    Document_type     VARCHAR(50)   NOT NULL CHECK (Document_type IN ('Petition', 'Reply', 'Affidavit', 'Order', 'Judgment', 'Notice', 'Vakalatnama', 'Other')),
    Filed_by          VARCHAR(20)   NOT NULL,
    Filed_date        DATE          NOT NULL,
    Document_address  TEXT          NOT NULL,
    CONSTRAINT PK_Case_document PRIMARY KEY (Document_ID),
    CONSTRAINT FK_Case_doc_Case FOREIGN KEY (Case_ID) REFERENCES "Case"(Case_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Case_doc_Hearing FOREIGN KEY (Hearing_ID) REFERENCES Hearing(Hearing_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Case_doc_Filed_by FOREIGN KEY (Filed_by) REFERENCES Lawyer(Bar_council_number) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE E_filing (
    Diary_number          INT           NOT NULL,
    Document_title        VARCHAR(255)  NOT NULL,
    Document_type         VARCHAR(50)   NOT NULL CHECK (Document_type IN ('Petition', 'Reply', 'Application', 'Appeal', 'Revision', 'Writ', 'Other')),
    Submit_date           DATE          NOT NULL,
    Status                VARCHAR(20)   NOT NULL CHECK (Status IN ('Submitted', 'Under Review', 'Verified', 'Rejected')),
    Petitioner_ID         INT               NULL,
    Admin_ID              INT           NOT NULL,
    Petitioner_lawyer_ID  VARCHAR(20)       NULL,
    CONSTRAINT PK_E_filing PRIMARY KEY (Diary_number),
    CONSTRAINT UQ_Diary_number UNIQUE (Diary_number),
    CONSTRAINT FK_E_filing_Petitioner FOREIGN KEY (Petitioner_ID) REFERENCES Litigant(Litigant_ID) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_E_filing_Admin FOREIGN KEY (Admin_ID) REFERENCES Admin(Admin_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_E_filing_Pet_Lawyer FOREIGN KEY (Petitioner_lawyer_ID) REFERENCES Lawyer(Bar_council_number) ON DELETE SET NULL ON UPDATE CASCADE
);
