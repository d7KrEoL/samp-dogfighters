#if !defined DIALOG_INPUT_VALIDATION
#define DIALOG_INPUT_VALIDATION
#define WRONG_INPUT (inputtext[i] == '%' || inputtext[i] == '&' || inputtext[i] > 126 || inputtext[i] < 32)
forward validateDialog(inputtext[]);
public validateDialog(inputtext[])
{
    new result = true;
    new i = 0;
    while (inputtext[i] != '\0')
    {
        printf("Input char[%d]: %c(%d)", i, inputtext[i], inputtext[i]);
        if(WRONG_INPUT)
        {
            printf("wrong input: %c", inputtext[i]);
            inputtext[i] = '\0';
            result = false;
        }
        i++;
    }
    return result;
}
#endif