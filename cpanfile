requires 'perl', '5.008005';

requires "Carp::Always",                 "0";
requires "HPC::Runner::Command",         "0";
requires "Cwd",                          "0";
requires "Data::Dumper",                 "0";
requires "DateTime",                     "0";
requires "DateTime::TimeZone",           "0";
requires "Env",                          "0";
requires "File::Details",                "0";
requires "File::Path",                   "0";
requires "List::Uniq",                   "0";
requires "Moose::Role",                  "0";
requires "Moose::Util::TypeConstraints", "0";
requires "Sys::Hostname",                "0";
requires "YAML",                         "0";
requires "YAML::XS",                     "0";
requires "namespace::autoclean",         "0";

on test => sub {
    requires 'Test::More',                 '0';
    requires "Capture::Tiny",              "0";
    requires "File::Slurp",                "0";
    requires "FindBin",                    "0";
    requires "HPC::Runner::Command",       "0";
    requires "IPC::Cmd",                   "0";
    requires "Slurp",                      "0";
    requires "Test::Class::Moose",         "0";
    requires "Test::Class::Moose::Load",   "0";
    requires "Test::Class::Moose::Runner", "0";
};
