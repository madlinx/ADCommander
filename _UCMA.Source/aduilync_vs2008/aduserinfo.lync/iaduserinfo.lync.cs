using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;

namespace ADUserInfo.Lync
{
    [ComVisible(true)]
    public interface IADUILyncContact
    {
        [ComVisible(true)]
        bool LyncClientSignin();

        [ComVisible(true)]
        void GetContactInfo(string ContactURI);

        [ComVisible(true)]
        string ContactName();

        [ComVisible(true)]
        int ContactAvailability();

        [ComVisible(true)]
        void FreeContact();
    }
}