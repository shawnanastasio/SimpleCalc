class expr
{
  I64 operator;
  I64 const1;
  I64 const2;
};

class atoi_result
{
  U8 success;
  I64 res;
};

U8 operators[5] = {'+', '-', '*', '-', '%'};


atoi_result *AToI(U8 *input)
{
  atoi_result *res = ACAlloc(sizeof(atoi_result));
  I64 final = 0;
  I64 i = 0;
  if (input[i] == '-') {
    ++i;
  }
  for (; i<StrLen(input); i++)
  {
    if (input[i]<'0' || input[i] > '9') {
      res->success = 0;
      return res;
    }
    final = final * 10;
    final = final + (input[i] - '0');
  }
  res->success = 1;
  if (input[0] == '-') {
    res->res = final * -1;
  } else {
    res->res = final;
  }
  return res;
}

// Return operator index in operators
// array if one is present in `str`
// Otherwise return -1
I64 GetOperator(U8 *str)
{
  I64 i, j;
  for (i=0; i<StrLen(str); i++)
  {
    if (i > 0 && str[i-1] != ' ')
      goto skip;
    if (i+1 < StrLen(str) && str[i+1] != ' ')
      goto skip;
    for (j=0; j<5; j++)
    {
      if (str[i] == operators[j])
        return j;
    }
  skip:
   
  }

  return -1;
 
}


I8 IsDelimiter(U8 char)
{
  I64 i, j;
  for (i=0; i<5; i++)
  {
    if (char == ' ' || char == '\0' || char == "")
      return 1;
    for (j=0; j<5; j++)
    {
      if (char == operators[j])
        return 1;
    } 
  }
  return 0;
}

//Get the first substring in `str`
// starting at `count` and output it
// into `out` and return new count
I64 Split(U8 *str, U8 *out, I64 count)
{
  I64 i;
  // Increase i until we get to a non-
  // delimiter char
  for (i=count; i<StrLen(str); i++)
  {
    if (!IsDelimiter(str[i]) || str[i] == '-') {
      break;
    }
  }
  I64 str_i = 0;
  for (; i<StrLen(str); i++)
  {
    // If we've hit a delimiter and
    // it's not the first char, break
    if (IsDelimiter(str[i])
        && str[i] != '-' && i != count) break;
    // Copy current char into `out`
    if (out != NULL){
      out[str_i] = str[i];
    }
    ++str_i;
  }
  return i;
}

expr* ParseExpr(U8 *str)
{
  expr *tmp = ACAlloc(sizeof(expr))(expr *);

  // Convert all shifted spaces to spaces
  I64 i;
  for (i=0; i<StrLen(str); i++)
  {
    if (str[i] == 31) {
      str[i] = ' ';
    }
  }
  
  // Parse first constant out of str
  I64 counter = 0;
  U8 *buf = ACAlloc(StrLen(str));
  counter = Split(str, buf, counter);
  atoi_result *res = AToI(buf); 
  if (!res->success) {
    return NULL;
  }
  tmp->const1 = res->res;
  Free(buf);
  Free(res);
  //"Got const1 %d\n",tmp->const1;

  // Parse operator out of str
  I64 opidx = GetOperator(str);
  if (opidx < 0) {
    // No operator in str! Error
    return NULL;
  }
  tmp->operator = operators[opidx];
  //"Got operator %c\n", operators[opidx];
  
  // Parse second constant out of str 
  buf = ACAlloc(StrLen(str));
  counter = Split(str, buf, counter);
  res = AToI(buf);
  if (!res->success) {
    return NULL;
  }
  tmp->const2 = res->res;
  //"Got const2 %d\n",tmp->const2;
  Free(buf);
  Free(res);


  return tmp;
}

I64 EvalExpr(expr *e)
{
  if (e->operator == '+') {
    return e->const1 + e->const2;
  } else if (e->operator == '-') {
    return e->const1 - e->const2;
  } else if (e->operator == '*') {
    return e->const1 * e->const2;
  } else if (e->operator == '/') {
    if (e->const2 == 0) {
      "ERROR: Can't divide by 0\n";
      return 0;
    }
    return e->const1 / e->const2;
  } else if (e->operator == '%') {
    return e->const1 % e->const2;
  } else {
    "ERROR: Unknown operation\n";
    return 0;
  }
}


U0 Main()
{
  "Welcome to SimpleCalc 1.0\n";
  "Enter a mathematical expression to evaluate.\n\n";
  "Enter nothing to exit\n";
  // Main program loop
  while(1)
  {
    // Display prompt
    "> ";
    I64 *input = GetStr();
    if (StrLen(input) == 0) break;

    // Parse input
    expr *expr_res = ParseExpr(input);
    if (!expr_res) {
      "Failed to parse expression!\n";
      goto cleanup;
    }

    // Evaluate expression
    I64 res = EvalExpr(expr_res);
    "%d\n", res;

  cleanup:
    // Free expression object
    Free(expr_res);

    // Free string
    Free(input);
  }
}

Main;
