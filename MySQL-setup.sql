CREATE DATABASE donors;



————— PROJECTS TABLE ——————

DROP TABLE IF EXISTS projects;

CREATE TABLE projects_new
(
  -- IDs
  _projectid VARCHAR(30) PNOT NULL,
  _teacher_acctid VARCHAR(30) NOT NULL,
  _schoolid VARCHAR(30) NOT NULL,
  school_ncesid VARCHAR(30),

  -- School Location
  school_latitude numeric(11,6),
  school_longitude numeric(11,6),
  school_city varchar(20),
  school_state varchar(2),
  school_zip varchar(20),
  school_metro varchar(20),
  school_district varchar(20),
  school_county varchar(20),

  -- School Types
  school_charter CHAR(1),
  school_magnet CHAR(1),
  school_year_round CHAR(1),
  school_nlns CHAR(1),
  school_kipp CHAR(1),
  school_charter_ready_promise CHAR(1),

  -- Teacher Attributes
  teacher_prefix varchar(20),
  teacher_teach_for_america CHAR(1),
  teacher_ny_teaching_fellow CHAR(1),

  -- Project Categories
  primary_focus_subject varchar(20),
  primary_focus_area varchar(20),
  secondary_focus_subject varchar(20),
  secondary_focus_area varchar(20),
  resource_type varchar(20),
  poverty_level varchar(20),
  grade_level varchar(20),

  -- Project Pricing and Impact
  vendor_shipping_charges numeric(10,2),
  sales_tax numeric(10,2),
  payment_processing_charges numeric(10,2),
  fulfillment_labor_materials numeric(10,2),
  total_price_excluding_optional_support numeric(10,2),
  total_price_including_optional_support numeric(10,2),
  students_reached integer,

  -- Project Donations
  total_donations numeric(10,2),
  num_donors integer,
  eligible_double_your_impact_match CHAR(1),
  eligible_almost_home_match CHAR(1),

  -- Project Status
  funding_status varchar(20),
  date_posted date,
  date_completed date,
  date_thank_you_packet_mailed date,
  date_expiration date,

  PRIMARY KEY (_projectid)

);


LOAD DATA LOCAL 
INFILE '~/DonorsChoose/opendata_projects.csv' 
INTO TABLE projects 
FIELDS TERMINATED BY "," 
LINES TERMINATED BY "\n" 
IGNORE 1 LINES;


—- Some data preprocessing in MySQL

UPDATE projects SET school_charter=FALSE WHERE school_charter='f';
UPDATE projects SET school_charter=TRUE WHERE school_charter='t';
UPDATE projects SET school_magnet=FALSE WHERE school_magnet='f';
UPDATE projects SET school_magnet=TRUE WHERE school_magnet='t';
UPDATE projects SET school_year_round=FALSE WHERE school_year_round='f';
UPDATE projects SET school_year_round=TRUE WHERE school_year_round='t';
UPDATE projects SET school_nlns=FALSE WHERE school_nlns='f';
UPDATE projects SET school_nlns=TRUE WHERE school_nlns='t';
UPDATE projects SET school_kipp =FALSE WHERE school_kipp='f';
UPDATE projects SET school_kipp =TRUE WHERE school_kipp='t';
UPDATE projects SET school_charter_ready_promise=FALSE WHERE school_charter_ready_promise='f';
UPDATE projects SET school_charter_ready_promise=TRUE WHERE school_charter_ready_promise='t';
UPDATE projects SET teacher_teach_for_america=FALSE WHERE teacher_teach_for_america='f';
UPDATE projects SET teacher_teach_for_america=TRUE WHERE teacher_teach_for_america='t';
UPDATE projects SET teacher_ny_teaching_fellow=FALSE WHERE teacher_ny_teaching_fellow='f';
UPDATE projects SET teacher_ny_teaching_fellow=TRUE WHERE teacher_ny_teaching_fellow='t';
UPDATE projects SET eligible_almost_home_match=FALSE WHERE eligible_almost_home_match='f';
UPDATE projects SET eligible_almost_home_match=TRUE WHERE eligible_almost_home_match='t';
UPDATE projects SET eligible_double_your_impact_match=FALSE WHERE eligible_double_your_impact_match='f';
UPDATE projects SET eligible_double_your_impact_match=TRUE WHERE eligible_double_your_impact_match='t';


— Finding projects in LA

CREATE TABLE projects_LA AS SELECT * FROM projects WHERE school_county =‘Los Angeles’;



/*

In case you want to have it as a CSV file:

SELECT *
FROM projects_LA
INTO OUTFILE '~/DonorsChoose/projects_la.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
*/




————— DONATION TABLE ——————


/*

Some data cleaning before importing is needed. Otherwise, the comma used in the donation message column 
will mess up everything. Note that it is imported as a CSV file into MySQL

sed 's/,",/",/g' opendata_donations.csv > tmpfile; mv tmpfile opendata_donations.csv
*/


DROP TABLE IF EXISTS donations;

CREATE TABLE donations
(
  -- IDs
  _donationid text NOT NULL,
  _projectid text NOT NULL,
  _donor_acctid text NOT NULL,
  _cartid text,

  -- Donor Info
  donor_city text,
  donor_state character(2),
  donor_zip text,
  is_teacher_acct text,

  -- Donation Times and Amounts
  donation_timestamp timestamp,
  donation_to_project text,
  donation_optional_support text,
  donation_total text,
  dollar_amount text,
  donation_included_optional_support text,

  -- Payment Types
  payment_method text,
  payment_included_acct_credit text,
  payment_included_campaign_gift_card text,
  payment_included_web_purchased_gift_card text,

  -- Donation Types
  payment_was_promo_matched text,
  via_giving_page text,
  for_honoree text,
  donation_message text,
  
  PRIMARY KEY (_donationid)

);



LOAD DATA LOCAL 
INFILE '~/DonorsChoose/opendata_donations.csv' 
INTO TABLE donations 
FIELDS TERMINATED BY "," 
LINES TERMINATED BY "\n" 
IGNORE 1 LINES;


—- Some data preprocessing in MySQL


UPDATE donations SET is_teacher_acct=TRUE WHERE is_teacher_acct='t';
UPDATE donations SET is_teacher_acct=FALSE WHERE is_teacher_acct='f';
UPDATE donations SET donation_included_optional_support=TRUE WHERE donation_included_optional_support='t';
UPDATE donations SET donation_included_optional_support=FALSE WHERE donation_included_optional_support='f';
UPDATE donations SET payment_included_acct_credit=TRUE WHERE payment_included_acct_credit='t';
UPDATE donations SET payment_included_acct_credit=FALSE WHERE payment_included_acct_credit='f';
UPDATE donations SET payment_included_campaign_gift_card=TRUE WHERE payment_included_campaign_gift_card='t';
UPDATE donations SET payment_included_campaign_gift_card=FALSE WHERE payment_included_campaign_gift_card='f';
UPDATE donations SET payment_included_web_purchased_gift_card=TRUE WHERE payment_included_web_purchased_gift_card='t';
UPDATE donations SET payment_included_web_purchased_gift_card=FALSE WHERE payment_included_web_purchased_gift_card='f';
UPDATE donations SET via_giving_page=TRUE WHERE via_giving_page='t';
UPDATE donations SET via_giving_page=FALSE WHERE via_giving_page='f';
UPDATE donations SET for_honoree=TRUE WHERE for_honoree='t';
UPDATE donations SET for_honoree=FALSE WHERE for_honoree='f';



/*

Finding donations make to LA projects

CREATE TABLE donation_LA AS 
SELECT donations._projectid, 
donations._donationid, 
donations.is_teacher_acct, 
donations.payment_method, 
donations.payment_included_acct_credit,
donations.payment_included_campaign_gift_card, 
donations.payment_included_web_purchased_gift_card, 
donations.donation_total, 
donations.dollar_amount,
donations.donation_timestamp,
donations.payment_was_promo_matched, 
donations.via_giving_page, 
donations.for_honoree, 
donations.donor_city, 
donations.donation_message,
donations.donation_timestamp, 
projects_LA.funding_status
FROM projects_LA JOIN donations ON projects_LA._projectid= donations._projectid;

*/



————— ESSAY TABLE ——————

/*
Word of caution: I won’t import it into MySQL right away.
As expected, there are so many commas in this file and
importing it as a CSV is a big mistake.

I had import it line by line into python and use regular expression
for cleaning it up.
*/


DROP TABLE IF EXISTS essays;

CREATE TABLE essays
(
  _projectid text NOT NULL,
  _teacher_acctid text NOT NULL,

  title text,
  short_description text,
  need_statement text,
  essay text,
  paragraph1 text,
  paragraph2 text,
  paragraph3 text,
  paragraph4 text,

  PRIMARY KEY (_projectid)
);

LOAD DATA LOCAL 
INFILE '~/DonorsChoose/opendata_essays.csv' 
INTO TABLE essays FIELDS 
TERMINATED BY '","' 
LINES TERMINATED BY "\n" 
IGNORE 1 LINES;



CREATE TABLE essay_LA AS 
SELECT essays._projectid, projects_LA.funding_status, essays.title,
essays.short_description, essays.need_statement, essays.essay, 
essays.paragraph1, essays.paragraph2, essays.paragraph3, essays.paragraph4
FROM projects_LA JOIN essays where projects_LA._projectid= essays._projectid;




