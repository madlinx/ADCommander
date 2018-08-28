using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Lync.Model;

namespace ADUserInfo.Lync
{
    [ComVisible(true)]
    public class ContactInfo : IADUILyncContact
    {
        private LyncClient _LyncClient;

        private ContactSubscription _ContactSubscription;

        private Contact _Contact;

        private List<ContactInformationType> _ContactInformationList = new List<ContactInformationType>();

        private int _ContactAvailability = -1;

        private string _ContactName = string.Empty;

        public ContactInfo()
        {
            LyncClientInitialization(false);
        }

        private void LyncClientInitialization(bool Signin)
        {
            try
            {
                _LyncClient = LyncClient.GetClient();
                _ContactSubscription = _LyncClient.ContactManager.CreateSubscription();

                _ContactInformationList.Clear();
                _ContactInformationList.Add(ContactInformationType.DisplayName);
                _ContactInformationList.Add(ContactInformationType.Availability);
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
                if (IsLyncException(systemException))
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

            if (Signin == true)
            {
                LyncClientSignin();
            }
        }

        private void SignInOut()
        {
            try
            {
                if (_LyncClient.State == ClientState.SignedIn)
                {
                    //Sign out If the current client state is Signed In
                    _LyncClient.BeginSignOut(SignOutCallback, null);
                }
                else if (_LyncClient.State == ClientState.SignedOut)
                {
                    //Sign in If the current client state is Signed Out
                    _LyncClient.BeginSignIn(null, null, null, SignInCallback, null);
                }
            }
            catch (LyncClientException lyncClientException)
            {
                // Console.WriteLine(lyncClientException);
            }
            catch (SystemException systemException)
            {
                if (IsLyncException(systemException))
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

        private void SignInCallback(IAsyncResult result)
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
                if (IsLyncException(systemException))
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

        private void SignOutCallback(IAsyncResult result)
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
                if (IsLyncException(systemException))
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

        private bool IsLyncException(SystemException ex)
        {
            return
                ex is NotImplementedException ||
                ex is ArgumentException ||
                ex is NullReferenceException ||
                ex is NotSupportedException ||
                ex is ArgumentOutOfRangeException ||
                ex is IndexOutOfRangeException ||
                ex is InvalidOperationException ||
                ex is TypeLoadException ||
                ex is TypeInitializationException ||
                ex is InvalidComObjectException ||
                ex is InvalidCastException;
        }

        [ComVisible(true)]
        public bool LyncClientSignin()
        {
            if (_LyncClient != null && _LyncClient.State == ClientState.SignedOut)
            {
                SignInOut();
            }
            return (_LyncClient.State == ClientState.SignedIn);
        }

        [ComVisible(true)]
        public void GetContactInfo(string ContactURI)
        {
            FreeContact();

            if (_LyncClient != null)
            {
                try
                {
                    _Contact = _LyncClient.ContactManager.GetContactByUri(ContactURI);
                    _Contact.SettingChanged += _Contact_SettingChanged;
                    _Contact.ContactInformationChanged += _Contact_ContactInformationChanged;
                    _Contact.UriChanged += _Contact_UriChanged;
                    _ContactSubscription.AddContact(_Contact);
                    _ContactSubscription.Subscribe(ContactSubscriptionRefreshRate.High, _ContactInformationList);

                    _ContactName = (string)_Contact.GetContactInformation(ContactInformationType.DisplayName);
                    _ContactAvailability = (int)(ContactAvailability)_Contact.GetContactInformation(ContactInformationType.Availability);
                }
                catch (LyncClientException e)
                {
                    FreeContact();
                    LyncClientInitialization(true);
                    // Console.WriteLine(e);
                }
                catch (SystemException systemException)
                {
                    if (IsLyncException(systemException))
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

        private void _Contact_UriChanged(object sender, UriChangedEventArgs e)
        {
            //throw new NotImplementedException();
        }

        private void _Contact_SettingChanged(object sender, ContactSettingChangedEventArgs e)
        {
            //throw new NotImplementedException();
        }

        private void _Contact_ContactInformationChanged(object sender, ContactInformationChangedEventArgs e)
        {
            if (e.ChangedContactInformation.Contains(ContactInformationType.DisplayName))
            {
                _ContactName = (string)_Contact.GetContactInformation(ContactInformationType.DisplayName);
            }

            if (e.ChangedContactInformation.Contains(ContactInformationType.Availability))
            {
                _ContactAvailability = (int)(ContactAvailability)_Contact.GetContactInformation(ContactInformationType.Availability);
            }
        }

        [ComVisible(true)]
        public string ContactName()
        {
            return _ContactName;
        }

        [ComVisible(true)]
        public int ContactAvailability()
        {
            return _ContactAvailability;
        }

        [ComVisible(true)]
        public void FreeContact()
        {
            _ContactName = string.Empty;
            _ContactAvailability = -1;
            try
            {
                _ContactSubscription.Unsubscribe();

                IList<Contact> _Contacts = _ContactSubscription.Contacts;
                foreach (Contact C in _Contacts)
                {
                    _ContactSubscription.RemoveContact(C);
                }

                //if (_Contact != null)
                //{
                //    _ContactSubscription.RemoveContact(_Contact);
                //}
            }
            catch
            {

            }
            _Contact = null;
        }
    }
}