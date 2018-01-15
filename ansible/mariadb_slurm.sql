drop database slurm_acct_db_1605;
drop database slurm_acct_db_1702;
drop database slurm_acct_db_1711;
drop database slurm_acct_db_master;

create database slurm_acct_db_1605;
create database slurm_acct_db_1702;
create database slurm_acct_db_1711;
create database slurm_acct_db_master;

grant usage on *.* to slurm@localhost identified by 'slurmpasswd';
grant all privileges on slurm_acct_db_1605.* to slurm@localhost;
grant all privileges on slurm_acct_db_1702.* to slurm@localhost;
grant all privileges on slurm_acct_db_1711.* to slurm@localhost;
grant all privileges on slurm_acct_db_master.* to slurm@localhost;
