unit ADC.ADObjectList;

interface

uses
  System.Classes, System.Generics.Collections, System.Generics.Defaults, System.SysUtils,
  System.DateUtils, System.StrUtils, System.Rtti, System.TypInfo, System.Math,
  System.RegularExpressions, Vcl.Imaging.jpeg, ActiveDs_TLB, ADC.Types,
  ADC.ADObject, ADC.Attributes;

type
  TADObjectSortOrder = (osoAscending, osoDescending);

type
  TADObjectList<T: TADObject> = class (TObjectList<T>)
  private
    type
      TADObjectFilter = class(TObject)
      private
        FOwner: TADObjectList<T>;
        FResultList: TADObjectList<T>;
        FAttrCat: TAttrCatalog;
        FEnabled: Boolean;
        FApplyOnChange: Boolean;
        FADPath: string;
        FObjects: Word;
        FCondition: string;
        FNameOnly: Boolean;
        FIncludeDisabled: Boolean;
        constructor Create(AOwner: TADObjectList<T>); reintroduce;
        procedure SetEnabled(const Value: Boolean);
        procedure SetADPath(const Value: string);
        procedure SetCondition(const Value: string);
        procedure SetNameOnly(const Value: Boolean);
        procedure SetIncludeDisabled(const Value: Boolean);
        function ProperyValue(Value: string): string; overload;
        function ProperyValue(Value: Integer): string; overload;
        function ProperyValue(Value: Double): string; overload;
        function ProperyValue(Value: Extended): string; overload;
        function ProperyValue(Value: TDateTime): string; overload;
        function SatisfiesCondition(AObject: TADObject; AProperties: TArray<TRttiProperty>): Boolean; overload;
        function SatisfiesCondition(AObject: TADObject): Boolean; overload;
        procedure SetObjects(const Value: Word);
      public
        procedure Apply;
        property Enabled: Boolean read FEnabled write SetEnabled;
        property AttrCatalog: TAttrCatalog read FAttrCat write FAttrCat;
        property ResultList: TADObjectList<T> read FResultList write FResultList;
        property ApplyOnChange: Boolean read FApplyOnChange write FApplyOnChange;
        property ADPath: string read FADPath write SetADPath;
        property Objects: Word read FObjects write SetObjects;
        property Condition: string read FCondition write SetCondition;
        property NameOnly: Boolean read FNameOnly write SetNameOnly;
        property IncludeDisabled: Boolean read FIncludeDisabled write SetIncludeDisabled;
    end;
  private
    FFilter: TADObjectFilter;
    FLastSortedProperty: string;
    FSortOrder: SmallInt;
    FUsersOnTop: Boolean;
    FObjOrder: SmallInt;
    FDisabledOrder: SmallInt;
    FOnSort: TNotifyEvent;
    FOnFilter: TNotifyEvent;
    procedure SetUsersOnTop(const Value: Boolean);
    function GetSortOrder: TADObjectSortOrder;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    destructor Destroy; override;
    procedure SortObjects(AProperty: string = '');
    property Filter: TADObjectFilter read FFilter;
    property UsersOnTop: Boolean read FUsersOnTop write SetUsersOnTop;
    property OnSort: TNotifyEvent read FOnSort write FOnSort;
    property OnFilter: TNotifyEvent read FOnFilter write FOnFilter;
    property SortOrder: TADObjectSortOrder read GetSortOrder;
    property SortedProperty: string read FLastSortedProperty;
  end;

implementation

{ TADObjectList<T> }

constructor TADObjectList<T>.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);

  FFilter := TADObjectFilter.Create(Self);
  FLastSortedProperty := 'name';
  FSortOrder := -1;
  FUsersOnTop := True;
  FObjOrder := 1;
  FDisabledOrder := 1;
end;

destructor TADObjectList<T>.Destroy;
begin
  FFilter.Free;
  inherited;
end;

function TADObjectList<T>.GetSortOrder: TADObjectSortOrder;
begin
  if FSortOrder < 0
    then Result := osoAscending
    else Result := osoDescending;
end;

procedure TADObjectList<T>.SetUsersOnTop(const Value: Boolean);
begin
  FUsersOnTop := Value;
  FObjOrder := StrToIntDef(IfThen(Value = True, '1', '-1'), 0);
end;

procedure TADObjectList<T>.SortObjects(AProperty: string);
var
  RTTIType: TRttiType;
  RTTIProperty: TRttiProperty;
  Context: TRTTIContext;
begin
  { Если сортировка не указана, то будет применена последняя }
  if AProperty.IsEmpty
    then FSortOrder := FSortOrder * -1
    else FLastSortedProperty := AProperty;

  Context := TRttiContext.Create;
  try
    RTTIType := Context.GetType(TypeInfo(T));
    RTTIProperty := RTTIType.GetProperty(FLastSortedProperty);
  finally
    Context.Free;
  end;

  Self.Sort(
    TComparer<T>.Construct(
      function (const L, R: T): Integer
      var
        LValue: TValue;
        RValue: TValue;
      begin
        LValue := RTTIProperty.GetValue(Pointer(L));
        RValue := RTTIProperty.GetValue(Pointer(R));

        if TADObject(L).SortPosition < TADObject(R).SortPosition
          then Result := -1 * FObjOrder
          else if TADObject(L).SortPosition > TADObject(R).SortPosition
            then Result := FObjOrder
            else case RTTIProperty.PropertyType.TypeKind of
              tkInteger: Result := FSortOrder * CompareValue(LValue.AsInt64, RValue.AsInt64);
              tkInt64: Result := FSortOrder * CompareValue(LValue.AsInt64, RValue.AsInt64);
              tkFloat: Result := FSortOrder * CompareValue(LValue.AsExtended, RValue.AsExtended);
              tkClass: begin
                if LValue.IsType<TJPEGImage>
                  then Result := FSortOrder * CompareValue(TADObject(L).thumbnailFileSize, TADObject(R).thumbnailFileSize);
              end
              else Result := FSortOrder * AnsiCompareText(LValue.AsString, RValue.AsString);
            end;
      end
    )
  );

  FSortOrder := FSortOrder * -1;

  if Assigned(FOnSort)
    then FOnSort(Self);
end;

{ TADObjectList<T>.TADObjectFilter }

procedure TADObjectList<T>.TADObjectFilter.Apply;
var
  obj: TADObject;
  RTTIType: TRttiType;
  RTTIProperties: TArray<TRttiProperty>;
  RTTIProperty: TRttiProperty;
  Context: TRTTIContext;
begin
  if (FResultList = nil) or (FAttrCat = nil)
    then Exit;

  FResultList.OwnsObjects := False;
  FResultList.Clear;

  Context := TRttiContext.Create;
  try
    RTTIType := Context.GetType(TypeInfo(T));
    RTTIProperties := RTTIType.GetProperties;

    for obj in FOwner do
    begin
      if ((not FIncludeDisabled) and (obj.userAccountControl and ADS_UF_ACCOUNTDISABLE <> 0))
      or ((obj.IsUser) and (FObjects and FILTER_OBJECT_USER = 0))
      or ((obj.IsGroup) and (FObjects and FILTER_OBJECT_GROUP = 0))
      or ((obj.IsWorkstation) and (FObjects and FILTER_OBJECT_WORKSTATION = 0))
      or ((obj.IsDomainController or obj.IsRODomainController) and (FObjects and FILTER_OBJECT_DC = 0))
        then Continue;

      case FEnabled of
        False: begin
          FResultList.Add(obj);
        end;

        True: begin
          if SatisfiesCondition(obj)  { <- Работает быстро}
//          if SatisfiesCondition(obj, RTTIProperties)  { <- Работает медленно}
            then FResultList.Add(obj);
        end;
      end;
    end;
  finally
    Context.Free;
  end;

  if Assigned(FOwner.OnFilter)
    then FOwner.OnFilter(FOwner);
end;

constructor TADObjectList<T>.TADObjectFilter.Create(
  AOwner: TADObjectList<T>);
begin
  inherited Create;
  FIncludeDisabled := True;
  FOwner := AOwner;
end;

function TADObjectList<T>.TADObjectFilter.ProperyValue(Value: Extended): string;
begin
  Result := FloatToStr(Value);
end;

function TADObjectList<T>.TADObjectFilter.ProperyValue(Value: Double): string;
begin
  Result := FloatToStr(Value);
end;

function TADObjectList<T>.TADObjectFilter.ProperyValue(Value: string): string;
begin
  Result := AnsiLowerCase(
    StringReplace(Value, 'ё', 'е', [rfReplaceAll, rfIgnoreCase])
  );
end;

function TADObjectList<T>.TADObjectFilter.ProperyValue(Value: Integer): string;
begin
  Result := IntToStr(Value);
end;

function TADObjectList<T>.TADObjectFilter.ProperyValue(
  Value: TDateTime): string;
begin
  Result := DateTimeToStr(Value);
end;

function TADObjectList<T>.TADObjectFilter.SatisfiesCondition(
  AObject: TADObject; AProperties: TArray<TRttiProperty>): Boolean;
var
  RegEx: TRegEx;
  reMatches: TMatchCollection;
  reValue: string;
  RTTIProperty: TRttiProperty;
begin
  Result := True;

  { Анализ пути AD }
  RegEx := TRegEx.Create(Format('^%s.*$', [TRegEx.Escape(Self.ADPath)]), [roIgnoreCase]);
  reMatches := TRegEx.Matches(AObject.canonicalName, '^.*(?=.*\/)', [roIgnoreCase]);
  if reMatches.Count > 0
    then reValue := reMatches.Item[0].Value;
  if (not Self.ADPath.IsEmpty) and (not RegEx.IsMatch(reValue)) then
  begin
    Result := False;
    Exit;
  end;

  { Анализ текста }
  { Используется динамический разбор свойств/полей объекта AObject, учитывается }
  { видимость поля в таблице, код выглядит красиво, но работпет ОЧЕНЬ МЕДЛЕННО  }
  if not Self.Condition.IsEmpty then
  begin
    RegEx := TRegEx.Create(Format('^.*%s.*$', [TRegEx.Escape(Self.Condition, True)]), [roIgnoreCase]);
    if FNameOnly then
    begin
      if not RegEx.IsMatch(AObject.name) then
      begin
        Result := False;
        Exit;
      end;
    end else
    begin
      Result := False;
      for RTTIProperty in AProperties do
      if FAttrCat.ItemByProperty(RTTIProperty.Name).Visible then
      try
        if RegEx.IsMatch(RTTIProperty.GetValue(Pointer(AObject)).AsString)
          then Result := True;
      except;

      end;
    end;
  end;
end;

function TADObjectList<T>.TADObjectFilter.SatisfiesCondition(
  AObject: TADObject): Boolean;
var
  attr: PADAttribute;
begin
  Result := True;

  { Анализ пути AD }
  if not ProperyValue(AObject.canonicalName).Contains(Self.ADPath) then
  begin
    Result := False;
    Exit;
  end;

  { Анализ текста }
  if not Self.Condition.IsEmpty then
  begin
    if FNameOnly then
    begin
      if Pos(Self.Condition, ProperyValue(AObject.name)) = 0 then
      begin
        Result := False;
        Exit;
      end;
    end else
    begin
      Result := False;

      { Вариант 1: без учета видимости полей в таблице | БЫСТРО }

      if (ProperyValue(AObject.Attribute01).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute02).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute03).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute04).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute05).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute06).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute07).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute08).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute09).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute10).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute11).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute12).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute13).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute14).Contains(Self.Condition))
      or (ProperyValue(AObject.Attribute15).Contains(Self.Condition))
      or (ProperyValue(AObject.name).Contains(Self.Condition))
      or (ProperyValue(AObject.lastLogon.AsString('<нет>')).Contains(Self.Condition))
      or (ProperyValue(AObject.badPwdCount).Contains(Self.Condition))
      or (ProperyValue(AObject.passwordExpiration.AsString).Contains(Self.Condition))
      or (ProperyValue(AObject.thumbnailFileSize.AsString).Contains(Self.Condition))
      or (ProperyValue(AObject.nearestEvent.AsString).Contains(Self.Condition))
      or (ProperyValue(AObject.canonicalName).Contains(Self.Condition))
      or (ProperyValue(AObject.distinguishedName).Contains(Self.Condition))
      or (ProperyValue(AObject.sAMAccountName).Contains(Self.Condition))
      or (ProperyValue(AObject.msRTCSIP_PrimaryUserAddress).Contains(Self.Condition))
      or (ProperyValue(AObject.objectSid).Contains(Self.Condition))
      or (ProperyValue(AObject.userAccountControl.AsString).Contains(Self.Condition))
        then Result := True;

      { Вариант 2: без учета видимости полей в таблице | БЫСТРО }

//      if (Pos(Self.Condition, ProperyValue(AObject.Attribute01)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute02)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute03)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute04)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute05)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute06)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute07)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute08)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute09)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute10)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute11)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute12)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute13)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute14)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.Attribute15)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.name)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.lastLogon.AsString('<нет>'))) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.badPwdCount)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.passwordExpiration)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.thumbnailFileSize)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.nearestEvent.AsString)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.canonicalName)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.distinguishedName)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.sAMAccountName)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.msRTCSIP_PrimaryUserAddress)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.objectSid)) > 0)
//      or (Pos(Self.Condition, ProperyValue(AObject.userAccountControl.AsString)) > 0)
//        then Result := True;

      { Вариант 3: с учетом видимости полей в таблице | МЕДЛЕННО }

//      for attr in FAttrCat  do
//      begin
//        if not attr.Visible
//          then Continue;
//
//        case IndexText(string(attr^.Name),
//        [
//          'Attribute01',                   {  0 }
//          'Attribute02',                   {  1 }
//          'Attribute03',                   {  2 }
//          'Attribute04',                   {  3 }
//          'Attribute05',                   {  4 }
//          'Attribute06',                   {  5 }
//          'Attribute07',                   {  6 }
//          'Attribute08',                   {  7 }
//          'Attribute09',                   {  8 }
//          'Attribute10',                   {  9 }
//          'Attribute11',                   { 10 }
//          'Attribute12',                   { 11 }
//          'Attribute13',                   { 12 }
//          'Attribute14',                   { 13 }
//          'name',                          { 14 }
//          'userWorkstations',              { 15 }
//          'lastLogon',                     { 16 }
//          'badPwdCount',                   { 17 }
//          'passwordExpiration',            { 18 }
//          'thumbnailPhoto',                { 19 }
//          'thumbnailFileSize',             { 20 }
//          'events',                        { 21 }
//          'nearestEvent',                  { 22 }
//          'canonicalName',                 { 23 }
//          'distinguishedName',             { 24 }
//          'sAMAccountName',                { 25 }
//          'msRTCSIP_PrimaryUserAddress',   { 26 }
//          'objectSid',                     { 27 }
//          'userAccountControl',            { 28 }
//          'ObjectPath_LDAP',               { 29 }
//          'ObjectPath_WinNT'               { 30 }
//        ]
//        ) of
//          0: if Pos(Self.Condition, ProperyValue(AObject.Attribute01)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          1: if Pos(Self.Condition, ProperyValue(AObject.Attribute02)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          2: if Pos(Self.Condition, ProperyValue(AObject.Attribute03)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          3: if Pos(Self.Condition, ProperyValue(AObject.Attribute04)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          4: if Pos(Self.Condition, ProperyValue(AObject.Attribute05)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          5: if Pos(Self.Condition, ProperyValue(AObject.Attribute06)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          6: if Pos(Self.Condition, ProperyValue(AObject.Attribute07)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          7: if Pos(Self.Condition, ProperyValue(AObject.Attribute08)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          8: if Pos(Self.Condition, ProperyValue(AObject.Attribute09)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          9: if Pos(Self.Condition, ProperyValue(AObject.Attribute10)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          10: if Pos(Self.Condition, ProperyValue(AObject.Attribute11)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          11: if Pos(Self.Condition, ProperyValue(AObject.Attribute12)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          12: if Pos(Self.Condition, ProperyValue(AObject.Attribute13)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          13: if Pos(Self.Condition, ProperyValue(AObject.Attribute14)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          14: if Pos(Self.Condition, ProperyValue(AObject.name)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          15: if Pos(Self.Condition, ProperyValue(AObject.userWorkstations)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          16: if Pos(Self.Condition, ProperyValue(AObject.lastLogon.AsString('<нет>'))) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          17: if Pos(Self.Condition, ProperyValue(AObject.badPwdCount)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          18: if Pos(Self.Condition, ProperyValue(AObject.passwordExpiration)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          19..20: if Pos(Self.Condition, ProperyValue(AObject.thumbnailFileSize)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          22: if Pos(Self.Condition, ProperyValue(AObject.nearestEvent.AsString)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          23: if Pos(Self.Condition, ProperyValue(AObject.canonicalName)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          24: if Pos(Self.Condition, ProperyValue(AObject.distinguishedName)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          25: if Pos(Self.Condition, ProperyValue(AObject.sAMAccountName)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          26: if Pos(Self.Condition, ProperyValue(AObject.msRTCSIP_PrimaryUserAddress)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          27: if Pos(Self.Condition, ProperyValue(AObject.objectSid)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//
//          28: if Pos(Self.Condition, ProperyValue(AObject.userAccountControl.AsString)) > 0 then
//          begin
//            Result := True;
//            Break;
//          end;
//        end;
//      end;
    end;
  end;
end;

procedure TADObjectList<T>.TADObjectFilter.SetADPath(const Value: string);
begin
  FADPath := AnsiLowerCase(Value);

  if FApplyOnChange
    then Self.Apply;
end;

procedure TADObjectList<T>.TADObjectFilter.SetCondition(const Value: string);
begin
  FCondition := AnsiLowerCase(Value);

  if FApplyOnChange
    then Self.Apply;
end;

procedure TADObjectList<T>.TADObjectFilter.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  Self.Apply;
end;

procedure TADObjectList<T>.TADObjectFilter.SetIncludeDisabled(
  const Value: Boolean);
begin
  FIncludeDisabled := Value;

  if FApplyOnChange
    then Self.Apply;
end;

procedure TADObjectList<T>.TADObjectFilter.SetNameOnly(const Value: Boolean);
begin
  FNameOnly := Value;

  if FApplyOnChange
    then Self.Apply;
end;

procedure TADObjectList<T>.TADObjectFilter.SetObjects(const Value: Word);
begin
  FObjects := Value;

  if FApplyOnChange
    then Self.Apply;
end;

end.
