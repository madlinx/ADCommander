using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;
using Microsoft.Lync.Model;

namespace ADCommander.UCMA
{
    [ComVisible(true)]
    [Guid("7F0A6F02-8FA2-46DB-A444-6962635218D5")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    public interface IUCMAContactEvents
    {
        [DispId(1000)]
        void OnClientSignIn();

        [DispId(1001)]
        void OnClientSignOut();

        [DispId(1002)]
        void OnClientDisconnected();
        
        [DispId(1003)]
        void OnSettingChanged();

        [DispId(1004)]
        void OnContactInformationChanged();

        [DispId(1005)]
        void OnUriChanged(string oldURI, string newURI);
    }
    
    [ComVisible(true)]
    [Guid("2DB3341F-909A-44EB-A36A-BD313980B269")]
    public interface IUCMAContact
    {
        [ComVisible(true)]
        bool ClientSignIn();

        [ComVisible(true)]
        void SetContact(string ContactURIorDN);

        [ComVisible(true)]
        void FreeContact();

        [ComVisible(true)]
        string DisplayName { get; }

        [ComVisible(true)]
        string Title { get; }

        [ComVisible(true)]
        string PersonalNote { get; }

        [ComVisible(true)]
        string Activity { get; }

        [ComVisible(true)]
        string ActivityID { get; }

        [ComVisible(true)]
        DateTime IdleStartTime { get; }

        [ComVisible(true)]
        int Availability { get; }

        [ComVisible(true)]
        byte[] Photo { get; }

        [ComVisible(true)]
        byte[] IconStream { get; }

        [ComVisible(true)]
        string PhotoHex { get; }

        [ComVisible(true)]
        string IconStreamHex { get; }
    }
}