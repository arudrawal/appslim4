<?php
/*
  MySQL Server supports three comment styles:
    From a # character to the end of the line.
    From a --  sequence to the end of the line. In MySQL, the --  (double-dash) comment 
	           style requires the second dash to be followed by at least one whitespace or 
			   control character (such as a space, tab, newline, and so on). 
			   This syntax differs slightly from standard SQL comment syntax, 
			   as discussed in Section 1.7.2.4, “'--' as the Start of a Comment”.
    From a C programming language style coment - like this header.
*/
class MysqlParser {
	/*
	 * remove single or milti-line commanets like this header.
	 * 		strips the sql comment lines out of an uploaded sql file
	 *		specifically for mssql and postgres type files in the install.
	 * preg-quote: puts a backslash in front of every character that is 
	 *             part of the regular expression syntax.
	 */
	function removeBlockComments($input) {
		$output = '';
		$lines = explode("\n", $input);
		$in_comment = false;
		foreach ($lines as $line) {
			if( preg_match("/^\/\*/", $line) ) {
				$in_comment = true;
			}

			if( !$in_comment ) {
				$output .= $line. "\n";
			}

			if( preg_match("/\*\/$/", $line) ) {
				$in_comment = false;
			}
		}
		return $output;
	}

	/*
	 * METHOD: remove single line remarks begining with #, --
	 *		strip the sql comment lines out of an uploaded sql file
	 */
	function removeRemarks($input) {
		$output = "";
		$lines = explode("\n", $input);	
		foreach ($lines as $line) {
			if (strlen($line) > 0) {
				if (isset($line[0]) && $line[0] == '#') {
					continue;
				}
				if (isset($line[0]) && $line[0] == '-') {
					if (isset($line[1]) && $line[1] == '-') {
						continue;
					}
				}
				$output .= $line. "\n";
			}
		}
		return $output;
	}
	
	/*
	 * Split sql file content into array of sql statements.
	 * return array of sql statements.
	 */
	function getSqlQueries($fileContent, $delimiter=';') {
		$out1 = self::removeBlockComments($fileContent);
		$out2 = self::removeRemarks($out1);
		return explode($delimiter, $out2);// SQL statements
	}
};
?>	
