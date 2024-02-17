--Qa. which prescriber had the highest total number of claims (totaled over all drugs)?Report the npi and the total number of claims.
SELECT prescriber.npi, sum(prescription.total_claim_count) AS total_claims 
FROM prescriber
INNER JOIN prescription 
ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY total_claims DESC
LIMIT 5
--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, sum(prescription.total_claim_count)
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name,specialty_description

--Q2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description AS s, sum(total_claim_count) AS total_count
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY s
ORDER BY total_count DESC
LIMIT 3
--ANSWER: Family Practice

--Q2b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description AS s, count(opioid_drug_flag) AS opioid_count
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
GROUP BY s
ORDER BY opioid_count DESC
LIMIT 3
--ANSWER Nurse Practitoner

--Q2c.
--Q2d

--Q3a. Which drug (generic_name) had the highest total drug cost?
SELECT d.drug_name,generic_name, sum(total_drug_cost) AS total_cost
FROM drug AS d
INNER JOIN prescription AS p
ON p.drug_name = d.drug_name
GROUP BY d.drug_name,generic_name
order by total_cost DESC
lIMIT 1
-- ANSWER PREGABALIN
--Q3b. Which drug(generic_name) has the highest total cost per day?
SELECT d.drug_name, generic_name, (total_drug_cost/total_day_supply) AS cost_per_day
FROM drug AS d
inner join prescription AS p
On d.drug_name = p.drug_name
order by cost_per_day desc
Limit 1
--ANSWER GAMMAGARD LIQUID
SELECT ROUND(7141.10666666666667, 2) 
--ANSWER: 7141.11

--Q4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have 
-- 'opioid' for drugs whch have opioid_drug_flag = 'Y', says 'antibiotic' for thse drugs which have antibiotic_drug_flag ='y',
-- and says 'neither' for all othe drugs.
SELECT drug_name, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither'
		 END AS drug_type
FROM drug;
--Q4b.Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT drug_name, SUM(total_drug_cost) AS MONEY
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither'
		 END AS  drug_type
FROM drug
INNER JOIN prescription 
ON prescription.drug_name = drug.drug_name
WHERE MONEY IN ('opioid', 'antibiotic')
GROUP BY drug_name

--Q5a. how many CBSAs are in Tennessee? 
select * from cbsa

SELECT count(cbsa)
FROM cbsa
INNER JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
WHERE state = 'TN'
--ANSWER: 42
--Q5b. which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsa, population 
FROM cbsa
INNER JOIN population
ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsa, population
ORDER BY population DESC
--ANSWER: The largest = 937847, The smalllest = 34980
--Q5C. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT population,county 
FROM population AS P
INNER JOIN fips_county AS F
on F.fipscounty = P.fipscounty
WHERE F.fipscounty NOT IN (select DISTINCT fipscounty from cbsa)
ORDER BY population DESC

select DISTINCT fipscounty from cbsa

--Q6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE  total_claim_count >= 3000
--Q6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT d.drug_name, total_claim_count,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		ELSE 'none'
		END AS Opioid
FROM prescription as p
INNER JOIN drug as d
ON d.drug_name = p.drug_name
WHERE total_claim_count >= 3000

--Q6c.Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT d.drug_name, total_claim_count,
nppes_provider_first_name as first_name, nppes_provider_last_org_name as last_name,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		ELSE 'none'
		END AS Opioid
FROM prescription as p
INNER JOIN drug as d
ON d.drug_name = p.drug_name
INNER JOIN prescriber as pr 
ON pr.npi = p.npi
WHERE total_claim_count >= 3000
--The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid.
--Q7a First, create a list of all npi/drug_name combinations for pain management specialist (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'Nashville'), where the drug is an opioid(opioid_drug_flag = 'Y').
--**Warning:** Double-check your query before running it. you will only need to use the prescriber and jdrug tables since you don't need the claims number yet.
SELECT  d.drug_name, pr.npi
FROM prescriber As pr
CROSS JOIN drug AS d
WHERE specialty_description ='Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
	
--Q7b.Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count)
SELECT  d.drug_name, pr.npi, total_claim_count
FROM prescriber As pr
CROSS JOIN drug AS d
LEFT JOIN prescription AS p
ON p.npi = pr.npi AND d.drug_name =p.drug_name
WHERE specialty_description ='Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
--Q 7C.Finally, if you have not done so already, fill in any missing values for total_claim_count with 0
SELECT COALESCE (total_claim_count,0)
FROM prescription
