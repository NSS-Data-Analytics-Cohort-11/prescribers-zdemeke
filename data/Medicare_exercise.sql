--Qa. which prescriber had the highest total number of claims (totaled over all drugs)?Report the npi and the total number of claims.
SELECT prescriber.npi, sum(prescription.total_claim_count) AS total_claims, 
FROM prescriber
INNER JOIN prescription 
ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY total_claims DESC
LIMIT 1
	--or
SELECT npi, sum(total_claim_count) as total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1									   											 				  
								   
--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,
SELECT prescriber.npi, sum(prescription.total_claim_count) AS total_claims, nppes_provider_last_org_name AS Last_name,
		nppes_provider_first_name AS First_name
FROM prescriber
INNER JOIN prescription 
ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi, Last_name, First_name
ORDER BY total_claims DESC
LIMIT 1

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
SELECT specialty_description AS s, SUM (total_claim_count) AS opioid_count
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY s
ORDER BY opioid_count DESC
LIMIT 1
--ANSWER Nurse Practitoner

--Q2c. Are there any specialties that appear in the prescriber table htat have no associated prescriptions in the prescription table?
SELECT specialty_description, SUM(total_claim_count) AS total_claim
FROM prescriber as pr
LEFT JOIN prescription AS p
on p.npi = pr.npi
GROUP BY specialty_description
HAVING SUM(total_claim_count) IS NULL
ORDER BY specialty_description

--Q2d FOR each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have percentage of opioids?
SELECT specialty_description, SUM(
		CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count
		ELSE 0 END) AS opioid_claims,
		
		SUM(total_claim_count) AS total_claims,
		
		SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count 
			ELSE 0 END) * 100.0/ SUM(total_claim_count) AS opioid_percentage
	FROM prescriber
	INNER JOIN prescription
	USING (npi)
	INNER JOIN drug
	USING (drug_name)
	GROUP BY specialty_description
	ORDER BY opioid_percentage DESC


--Q3a. Which drug (generic_name) had the highest total drug cost?
SELECT d.generic_name, sum(total_drug_cost) AS total_cost
FROM drug AS d
INNER JOIN prescription AS p
ON p.drug_name = d.drug_name
GROUP BY d.generic_name
order by total_cost DESC
lIMIT 1
-- ANSWER: INSULIN GLARGINE

--Q3b. Which drug(generic_name) has the highest total cost per day?
SELECT generic_name, ROUND(sum(total_drug_cost)/sum(total_day_supply), 2) AS cost_per_day
FROM drug AS d
inner join prescription AS p
On d.drug_name = p.drug_name
GROUP BY generic_name
order by cost_per_day desc
Limit 1
--ANSWER: C1 ESTERASE INHIBITOR

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
SELECT MONEY (SUM(total_drug_cost)) AS total_cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither'
		 END AS  drug_type
		 --or you can add it here SUM(total_drug_cost)::MONEY AS total_cost to format the total cost as MONEY or use CAST
		 
FROM drug AS d
INNER JOIN prescription 
ON prescription.drug_name = d.drug_name
GROUP BY drug_type
ORDER BY total_cost DESC

--Q5a. how many CBSAs are in Tennessee? 
select * from cbsa

SELECT count(cbsa)
FROM cbsa
INNER JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
WHERE state = 'TN'
--ANSWER: 42
--Q5b. which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, population 
FROM cbsa
INNER JOIN population
ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsaname,population
ORDER BY population DESC
--ANSWER: The largest = 937847, The smalllest = 34980
--Q5C. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT population,county 
FROM population AS P
INNER JOIN fips_county AS F
on F.fipscounty = P.fipscounty
WHERE F.fipscounty NOT IN (select DISTINCT fipscounty from cbsa)
ORDER BY population DESC
LIMIT 1
--ANSWER: SEVIER

select DISTINCT fipscounty from cbsa

--Q6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE  total_claim_count >= 3000
--Q6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT d.drug_name, total_claim_count,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		ELSE 'none'
		END AS drug_type
FROM prescription as p
INNER JOIN drug as d
ON d.drug_name = p.drug_name
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC

--Q6c.Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT d.drug_name, total_claim_count,
nppes_provider_first_name as first_name, nppes_provider_last_org_name as last_name,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		ELSE 'none'
		END AS drug_type
FROM prescription as p
INNER JOIN drug as d
ON d.drug_name = p.drug_name
INNER JOIN prescriber as pr 
ON pr.npi = p.npi
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC
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
ORDER BY pr.npi DESC
--Q 7C.Finally, if you have not done so already, fill in any missing values for total_claim_count with 0
SELECT
FROM prescription

SELECT  d.drug_name, pr.npi, COALESCE (total_claim_count,0)
FROM prescriber As pr
CROSS JOIN drug AS d
LEFT JOIN prescription AS p
USING(npi,drug_name)
WHERE specialty_description ='Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
ORDER BY pr.npi DESC								  
								   
								   
