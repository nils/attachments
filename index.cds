using { cuid, managed } from '@sap/cds/common';

type Image : Composition of sap.attachments.Images;
type Attachments : Association to sap.attachments.Attachments;

context sap.attachments {

  // Used in cds-plugin.js as template for attachments
  aspect aspect @(UI.Facets: [{
    $Type                : 'UI.ReferenceFacet',
    ID                   : 'AttachmentsFacet',
    Label                : '{i18n>Attachments}',
    Target               : 'attachments/@UI.PresentationVariant'
  }]) {
    attachments    : Association to many AttachmentsTable
                     on attachments.object = ID;
    key ID  : UUID;
  }

  entity AttachmentsTable as
    select from Documents {
      *,
      attachments.object as object
     };

  entity Images : cuid, managed, MediaData {}

  entity Documents : cuid, managed, MediaData {
        note        : String;
        attachments : Association to Attachments;
  }

  entity Attachments : cuid, managed {
    object : UUID @odata.Type:'Edm.String';
    createdAt : managed:createdAt @title: 'On';
    createdBy : managed:createdBy @title: 'By';
    documents : Composition of many Documents
                on documents.attachments = $self;
  }

  type MediaData {
    fileName : String;
    content   : LargeBinary @title: 'Attachment' @Core.MediaType: mimeType @Core.ContentDisposition.Filename: fileName @Core.Immutable: true;
    mimeType  : String @title: 'Attachment Type' @Core.IsMediaType: true;
    url       : String;
  }

  annotate AttachmentsTable with @(UI: {
    MediaResource: {
      Stream: content
    },
    PresentationVariant: {
      Visualizations: ['@UI.LineItem'],
      SortOrder     : [{
        Property  : createdAt,
        Descending: true
      }],
    },
    LineItem: [
      {Value: createdAt},
      {Value: createdBy},
      {Value: content},
      {Value: note}
    ],
    DeleteHidden       : true,
  });

}
