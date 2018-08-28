using System;
using System.Collections.Generic;
using System.IO;
using System.DirectoryServices;
using System.EnterpriseServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using Microsoft.Lync.Model;

namespace ADCommander.UCMA
{
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [ComSourceInterfaces(typeof(IUCMAContactEvents))]
    [ProgId("ADCommander.UCMA")]
    public class UCMAContact: ServicedComponent, IUCMAContact
    {
        private LyncClient _LyncClient = null;
        private ContactSubscription _ContactSubscription;
        private Contact _Contact;
        private List<ContactInformationType> _ContactInformationList = new List<ContactInformationType>();
        private Regex _RegExDistinguishedName = new Regex("^([a-z]{2,}=[^,]+,)+(DC=[a-z]+)+$", RegexOptions.IgnoreCase);

        private const int _Availability_Unknown = -1;

        private string _DisplayName = string.Empty;
        private string _Title = string.Empty;
        private string _PersonalNote = string.Empty;
        private string _Activity = string.Empty;
        private string _ActivityId = string.Empty;
        private DateTime _IdleStartTime = DateTime.Now;
        private int _Availability = _Availability_Unknown;
        private byte[] _Photo;
        private byte[] _IconStream;

        public delegate void OnClientDisconnectedDelegate();
        private event OnClientDisconnectedDelegate OnClientDisconnected;

        public delegate void OnClientSignInDelegate();
        private event OnClientSignInDelegate OnClientSignIn;

        public delegate void OnClientSignOutDelegate();
        private event OnClientSignOutDelegate OnClientSignOut;

        public delegate void OnContactInformationChangedDelegate();
        private event OnContactInformationChangedDelegate OnContactInformationChanged;

        public delegate void OnSettingChangedDelegate();
        private event OnSettingChangedDelegate OnSettingChanged;

        public delegate void OnUriChangedDelegate(string oldURI, string newURI);
        private event OnUriChangedDelegate OnUriChanged;

        public UCMAContact()
        {
            _LyncClientInitialization();
        }

        private string _GetContactURIByDistinguishedName(string DN)
        {
            const string attr = "msRTCSIP-PrimaryUserAddress";
            string res = string.Empty;
            Regex regEx = new Regex("DC=.+$", RegexOptions.IgnoreCase);
            string DomainPath = "LDAP://" + regEx.Match(DN);
            
            try
            {
                DirectoryEntry searchRoot = new DirectoryEntry(DomainPath);
                DirectorySearcher search = new DirectorySearcher(searchRoot);
                search.Filter = "(&(objectClass=user)(objectCategory=person)(distinguishedName=" + DN + "))";
                search.PropertiesToLoad.Add("msRTCSIP-PrimaryUserAddress");
                System.DirectoryServices.SearchResult result;
                result = search.FindOne();
                if (result != null)
                {
                    if (result.Properties.Contains(attr))
                    {
                        res = (string)result.Properties[attr][0];
                    }
                }
            }
            catch (Exception ex)
            {
                res = string.Empty;
            }

            return res;
        }

        private byte[] _GetContactImageBytes(Contact contact, ContactInformationType imageType)
        {
            if (
                contact == null || 
                imageType != ContactInformationType.Photo && imageType != ContactInformationType.IconStream
            )
            {
                return new byte[0];
            }

            Stream imgStream = null;
            
            try
            {
                imgStream = (Stream)contact.GetContactInformation(imageType); 
            }
            catch
            {
                return new byte[0];
            }

            if (imgStream == null)
            {
                return new byte[0];
            }

            byte[] buffer = new byte[16 * 1024];

            using (MemoryStream ms = new MemoryStream())
            {
                int read;
                while ((read = imgStream.Read(buffer, 0, buffer.Length)) > 0)
                {
                    ms.Write(buffer, 0, read);
                }
                return ms.ToArray();
            }
        }

        private DateTime _GetContactIdleStartTime(Contact contact)
        {
            try
            { 
                return ((DateTime)contact.GetContactInformation(ContactInformationType.IdleStartTime)).ToLocalTime(); 
            }
            catch
            {
                return DateTime.Now; 
            }
        }

        private void _GetContactInfo()
        {
            if (_Contact != null)
            {
                this._DisplayName = (string)_Contact.GetContactInformation(ContactInformationType.DisplayName);
                this._Title = (string)_Contact.GetContactInformation(ContactInformationType.Title);
                this._PersonalNote = (string)_Contact.GetContactInformation(ContactInformationType.PersonalNote);
                this._Activity = (string)_Contact.GetContactInformation(ContactInformationType.Activity);
                this._ActivityId = (string)_Contact.GetContactInformation(ContactInformationType.ActivityId);
                this._IdleStartTime = _GetContactIdleStartTime(_Contact);
                this._Availability = (int)(ContactAvailability)_Contact.GetContactInformation(ContactInformationType.Availability);
                this._Photo = _GetContactImageBytes(_Contact, ContactInformationType.Photo);
                this._IconStream = _GetContactImageBytes(_Contact, ContactInformationType.IconStream);
            }
            else _ClearContactInfo();
        }

        private void _ClearContactInfo()
        {
            this._DisplayName = string.Empty;
            this._Title = string.Empty;
            this._PersonalNote = string.Empty;
            this._IdleStartTime = DateTime.Now;
            this._Activity = string.Empty;
            this._ActivityId = string.Empty;
            this._Availability = _Availability_Unknown;
            this._Photo = new byte[0];
            this._IconStream = new byte[0];
        }

        private void _LyncClientInitialization()
        {
            _LyncClient = null;

            try
            {
                _LyncClient = LyncClient.GetClient();
                _LyncClient.ClientDisconnected += _ClientDisconnected;
                _LyncClient.StateChanged += _ClientStateChanged;

                _ContactSubscription = _LyncClient.ContactManager.CreateSubscription();

                _ContactInformationList.Clear();
                //_ContactInformationList.Add(ContactInformationType.DisplayName);
                //_ContactInformationList.Add(ContactInformationType.Title);
                _ContactInformationList.Add(ContactInformationType.PersonalNote);
                _ContactInformationList.Add(ContactInformationType.Activity);
                //_ContactInformationList.Add(ContactInformationType.ActivityId);
                _ContactInformationList.Add(ContactInformationType.IdleStartTime);
                _ContactInformationList.Add(ContactInformationType.Availability);
                //_ContactInformationList.Add(ContactInformationType.Photo);
                //_ContactInformationList.Add(ContactInformationType.IconStream);
            }
            catch (ClientNotFoundException clientNotFoundException)
            {
                // Console.WriteLine(clientNotFoundException);
                return;
            }
            catch (NotStartedByUserException notStartedByUserException)
            {
                // Console.Out.WriteLine(notStartedByUserException);
                return;
            }
            catch (LyncClientException lyncClientException)
            {
                // Console.Out.WriteLine(lyncClientException);
                return;
            }
            catch (SystemException systemException)
            {
                if (_IsLyncException(systemException))
                {
                    // Log the exception thrown by the Lync Model API.
                    // Console.WriteLine("Error: " + systemException);
                    return;
                }
                else
                {
                    // Rethrow the SystemException which did not come from the Lync Model API.
                    throw;
                }
            }
        }

        private void _SignInOut()
        {
            try
            {
                if (_LyncClient.State == ClientState.SignedIn)
                {
                    //Sign out If the current client state is Signed In
                    _LyncClient.BeginSignOut(_SignOutCallback, null);
                }
                else if (_LyncClient.State == ClientState.SignedOut)
                {
                    //Sign in If the current client state is Signed Out
                    _LyncClient.BeginSignIn(null, null, null, _SignInCallback, null);
                }
            }
            catch (LyncClientException e)
            {
                // Console.WriteLine(lyncClientException);
            }
            catch (SystemException systemException)
            {
                if (_IsLyncException(systemException))
                {
                    // Log the exception thrown by the Lync Model API.
                    // Console.WriteLine("Error: " + systemException);
                }
                else
                {
                    // Rethrow the SystemException which did not come from the Lync Model API.
                    throw;
                }
            }
        }

        private void _SignInCallback(IAsyncResult result)
        {
            try
            {
                _LyncClient.EndSignIn(result);
            }
            catch (LyncClientException e)
            {
                // Console.WriteLine(e);
            }
            catch (SystemException systemException)
            {
                if (_IsLyncException(systemException))
                {
                    // Log the exception thrown by the Lync Model API.
                    // Console.WriteLine("Error: " + systemException);
                }
                else
                {
                    // Rethrow the SystemException which did not come from the Lync Model API.
                    throw;
                }
            }
        }

        private void _SignOutCallback(IAsyncResult result)
        {
            try
            {
                _LyncClient.EndSignOut(result);
            }
            catch (LyncClientException e)
            {
                // Console.WriteLine(e);
            }
            catch (SystemException systemException)
            {
                if (_IsLyncException(systemException))
                {
                    // Log the exception thrown by the Lync Model API.
                    // Console.WriteLine("Error: " + systemException);
                }
                else
                {
                    // Rethrow the SystemException which did not come from the Lync Model API.
                    throw;
                }
            }
        }

        private bool _IsLyncException(SystemException e)
        {
            return
                e is NotImplementedException ||
                e is ArgumentException ||
                e is NullReferenceException ||
                e is NotSupportedException ||
                e is ArgumentOutOfRangeException ||
                e is IndexOutOfRangeException ||
                e is InvalidOperationException ||
                e is TypeLoadException ||
                e is TypeInitializationException ||
                e is InvalidComObjectException ||
                e is InvalidCastException;
        }

        [ComVisible(true)]
        public bool ClientSignIn()
        {
            if (_LyncClient == null || _LyncClient.State == ClientState.Invalid)
                _LyncClientInitialization();
            
            if (_LyncClient == null)
            {
                return false;
            }
            else
            {
                if (_LyncClient.State == ClientState.SignedOut)
                {
                    _SignInOut();
                }
                
                return (_LyncClient.State == ClientState.SignedIn);
            }
        }

        [ComVisible(true)]
        public void SetContact(string ContactURIorDN)
        {
            FreeContact();

            if (_LyncClient != null)
            {
                string ContactURI = string.Empty;
                
                if (_RegExDistinguishedName.IsMatch(ContactURIorDN))
                {
                    ContactURI = _GetContactURIByDistinguishedName(ContactURIorDN);
                }
                else
                {
                    ContactURI = ContactURIorDN;
                }

                try
                {
                    _Contact = _LyncClient.ContactManager.GetContactByUri(ContactURI);
                    _Contact.SettingChanged += _ContactSettingChanged;
                    _Contact.ContactInformationChanged += _ContactInformationChanged;
                    _Contact.UriChanged += _ContactUriChanged;
                    _ContactSubscription.AddContact(_Contact);
                    _ContactSubscription.Subscribe(ContactSubscriptionRefreshRate.High, _ContactInformationList);

                    _GetContactInfo();
                }
                catch (LyncClientException e)
                {
                    FreeContact(); 
                    _LyncClientInitialization();
                    ClientSignIn();
                    // Console.WriteLine(e);
                }
                catch (SystemException systemException)
                {
                    if (_IsLyncException(systemException))
                    {
                        // Log the exception thrown by the Lync Model API.
                        // Console.WriteLine("Error: " + systemException);
                    }
                    else
                    {
                        // Rethrow the SystemException which did not come from the Lync Model API.
                        throw;
                    }
                    FreeContact();
                }
            }
        }

        private void _ClientDisconnected(object sender, EventArgs e)
        {
            FreeContact();

            _LyncClient.ClientDisconnected -= _ClientDisconnected;
            _LyncClient.StateChanged -= _ClientStateChanged;

            if (this.OnClientDisconnected != null) OnClientDisconnected();
        }

        private void _ClientStateChanged(object sender, ClientStateChangedEventArgs e)
        {
            switch (e.NewState)
            {
                case ClientState.SignedIn:
                    if (this.OnClientSignIn != null) OnClientSignIn();
                    break;

                case ClientState.SignedOut:
                    if (this.OnClientSignOut != null) OnClientSignOut();
                    break;
            }
        }

        private void _ContactUriChanged(object sender, UriChangedEventArgs e)
        {
            //throw new NotImplementedException();

            if (this.OnUriChanged != null) OnUriChanged(e.OldUri, e.NewUri);
        }

        private void _ContactSettingChanged(object sender, ContactSettingChangedEventArgs e)
        {
            //throw new NotImplementedException(); 

            if (this.OnSettingChanged != null) OnSettingChanged();
        }

        private void _ContactInformationChanged(object sender, ContactInformationChangedEventArgs e)
        {
            _GetContactInfo();
            
            if (OnContactInformationChanged != null) OnContactInformationChanged();
        }

        [ComVisible(true)]
        public string DisplayName
        {
            get { return _DisplayName; }
        }

        [ComVisible(true)]
        public string Title
        {
            get { return _Title; }
        }

        [ComVisible(true)]
        public string PersonalNote
        {
            get { return _PersonalNote; }
        }

        [ComVisible(true)]
        public string Activity
        {
            get { return _Activity; }
        }

        [ComVisible(true)]
        public string ActivityID
        {
            get { return _ActivityId; }
        }

        [ComVisible(true)]
        public DateTime IdleStartTime
        {
            get { return _IdleStartTime; }
        }
        
        [ComVisible(true)]
        public int Availability
        {
            get { return _Availability; }
        }

        [ComVisible(true)]
        public byte[] Photo
        {
            get { return _Photo; }
        }

        [ComVisible(true)]
        public byte[] IconStream
        {
            get { return _IconStream; }
        }

        [ComVisible(true)]
        public string PhotoHex
        {
            get 
            { 
                string s = string.Empty;

                try
                {
                    s = BitConverter.ToString(_Photo);
                }
                catch
                {
                    s = string.Empty;
                }

                return s; 
            }
        }

        [ComVisible(true)]
        public string IconStreamHex
        {
            get 
            { 
                string s = string.Empty;

                try
                {
                    s = BitConverter.ToString(_IconStream);
                }
                catch
                {
                    s = string.Empty;
                }

                return s;
            }
        }

        [ComVisible(true)]
        public void FreeContact()
        {
            _ClearContactInfo();
            
            try
            {
                this._ContactSubscription.Unsubscribe();

                IList<Contact> _Contacts = this._ContactSubscription.Contacts;
                foreach (Contact C in _Contacts)
                {
                    this._ContactSubscription.RemoveContact(C);

                    C.SettingChanged -= _ContactSettingChanged;
                    C.ContactInformationChanged -= _ContactInformationChanged;
                    C.UriChanged -= _ContactUriChanged;
                }
            }
            catch
            {

            }

            this._Contact = null;
        }
    }
}